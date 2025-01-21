import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/quatationController.dart';
import '../model/coustomer_detail_model.dart';
import 'quatation_generate_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  QuatationCotroller controller = Get.put(QuatationCotroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quatation List"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CoustomerDetailModel>>(
        stream: controller.fetchCustomerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (controller.coustomerDetailModel.isNotEmpty) {
              return ListView(
                children: controller.coustomerDetailModel.map(
                  (coustomerDetail) {
                    return Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red[900],
                            child: Text(
                              coustomerDetail.quatationNumber!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                children: [
                                  const Icon(Icons.person),
                                  Text(
                                    coustomerDetail.coustomerName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    coustomerDetail.date!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.calendar_month),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                children: [
                                  const Icon(Icons.location_on_outlined),
                                  Text(
                                    coustomerDetail.location!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    coustomerDetail.time!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.access_time),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                children: [
                                  const Icon(Icons.call),
                                  Text(
                                    coustomerDetail.mobileNumber!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    coustomerDetail.projectType!.value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.location_city),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            children: [
                              const Icon(Icons.home_work_sharp),
                              const SizedBox(width: 8),
                              Text(
                                coustomerDetail.address!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.deepOrange),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    Wrap(
                                      children: [
                                        const Icon(
                                          Icons.solar_power_sharp,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        Text(
                                          " ${coustomerDetail.projectDetails!.panelCompany}",
                                          style: const TextStyle(
                                              color: Colors.orangeAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      color: Colors.white,
                                      child: null,
                                    ),
                                    Wrap(
                                      children: [
                                        const Icon(
                                          Icons.battery_4_bar_rounded,
                                          color: Colors.green,
                                          size: 26,
                                        ),
                                        Text(
                                          coustomerDetail.projectDetails!
                                              .inverterCompany!.value
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.deepOrangeAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    child: Text(
                                      coustomerDetail
                                          .projectDetails!.kw!.value!,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Text(
                                        coustomerDetail
                                            .projectDetails!.panelType!.value,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: coustomerDetail
                                                .projectDetails!.watt!.value
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.orangeAccent,
                                                fontWeight: FontWeight
                                                    .bold), // White color for 540
                                          ),
                                          const TextSpan(
                                            text: " Watt",
                                            style: TextStyle(
                                                color: Colors
                                                    .white), // Black color for watt
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      color: Colors.white,
                                      child: null,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: coustomerDetail
                                                .projectDetails!
                                                .noOfPanel!
                                                .value
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.deepOrangeAccent,
                                                fontWeight: FontWeight
                                                    .bold), // White color for 540
                                          ),
                                          const TextSpan(
                                            text: ' Panel',
                                            style: TextStyle(
                                                color: Colors
                                                    .white), // Black color for watt
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      "System Total Payable",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      coustomerDetail
                                          .projectDetails!.totalPayable!.value
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      "After Subsidy",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      coustomerDetail.projectDetails!
                                          .customerPayable!.value
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              );
            } else {
              return const Center(
                child: Text("No Any Data Available"),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(QuatationGeneratePage()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
