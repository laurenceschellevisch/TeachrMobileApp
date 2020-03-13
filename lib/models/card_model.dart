import 'package:flutter/material.dart';

class CardModel {
  final int id;
  final DecorationImage schoolImage;
  final String schoolName;
  final String jobTitle;
  final List<String> skills;
  final String jobTime;
  final String salary;
  final String explanation;
  final String city;
  final String postalCode;
  final String distance;
  final String jobCreateDate;
  final String jobStartDate;
  final String sector;
  final String contactName;
  final String schoolWebsite;

  CardModel(
      this.id,
      this.schoolImage,
      this.schoolName,
      this.jobTitle,
      this.skills,
      this.jobTime,
      this.salary,
      this.explanation,
      this.city,
      this.jobCreateDate,
      this.postalCode,
      this.distance,
      this.jobStartDate,
      this.sector,
      this.contactName,
      this.schoolWebsite);
}
