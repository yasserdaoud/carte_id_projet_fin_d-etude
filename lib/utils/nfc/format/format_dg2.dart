import '../../../library/dmrtd_lib/src/lds/df1/efdg2.dart';



String formatDG2(final EfDG2 dg2) {
  return "DG2\n"
      "faceImageType ${dg2.faceImageType}\n" +
      "facialRecordDataLength ${dg2.facialRecordDataLength}\n" +
      "imageHeight ${dg2.imageHeight}\n" +
      "imageType: ${dg2.imageType}\n" +
      "lengthOfRecord ${dg2.lengthOfRecord}\n" +
      "numberOfFacialImages ${dg2.numberOfFacialImages}\n" +
      "poseAngle ${dg2.poseAngle}";
}