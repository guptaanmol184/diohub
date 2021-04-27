import 'package:dio_hub/common/animations/scale_expanded_widget.dart';
import 'package:dio_hub/common/auth_popup/widgets/base_auth_dialog.dart';
import 'package:flutter/material.dart';

class SuccessPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaleExpandedSection(
      child: BaseAuthDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successful.',
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(
              height: 32,
            ),
            Text(
              'Authentication completed successfully.',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Divider(
              height: 32,
            ),
            Center(
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Tap here to close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
