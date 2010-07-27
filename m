Received: from mx2.netapp.com ([216.240.18.37]:41744 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754803Ab0G0PiE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 11:38:04 -0400
Received: from [10.1.33.112] (ski-core.hq.netapp.com [10.58.50.14])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o6RFbxbG018174
	for <linux-nfs@vger.kernel.org>; Tue, 27 Jul 2010 08:38:01 -0700 (PDT)
From: Andy Adamson <andros@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: pNFS client structure and function rename suggestions
Sender: "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
Date: Tue, 27 Jul 2010 11:38:13 -0400
Message-ID: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>
Content-Type: multipart/mixed;
	boundary="_002_DD09EF29A7044F17B917C01051355CA3netappcom_"
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--_002_DD09EF29A7044F17B917C01051355CA3netappcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <E97D8D436AD4E844949D9780264BE299@namprd02.prod.outlook.com>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
</head>
<body>
<div class="BodyFragment"><font size="2"><span style="font-size:11pt;">
<div class="PlainText">As per our last pNFS conference call, here is a list of suggested renames for discussion<br>
<br>
--&gt;Andy<br>
<br>
</div>
</span></font></div>
<div class="BodyFragment"><font size="2"><span style="font-size:11pt;">
<div class="PlainText"><br>
<br>
</div>
</span></font></div>
</body>
</html>

--_002_DD09EF29A7044F17B917C01051355CA3netappcom_
Content-Type: text/plain; name="pnfs-client-rename.txt"
Content-Description: pnfs-client-rename.txt
Content-Disposition: attachment; filename="pnfs-client-rename.txt"; size=2971;
	creation-date="Thu, 25 Jan 2018 00:31:07 GMT";
	modification-date="Thu, 25 Jan 2018 00:31:07 GMT"
Content-ID: <69595A8F8FAC8E4CB3253E1E28A90834@namprd02.prod.outlook.com>
Content-Transfer-Encoding: base64

KioqKioqKioqDQppbmNsdWRlL2xpbnV4L25mc19mcy5oDQoNCnN0cnVjdCBwbmZzX2xheW91dF90
eXBlID0+IHBuZnNfbGF5b3V0DQpmaWVsZHM6DQogICAgcmVmY291bnQgPT4gbG9fcmVmY291bnQN
CiAgICBzZWdzID0+IGxvX3NlZ3MNCiAgICByb2NfaW9tb2RlID0+IGxvX3JvY19pb21vZGUNCiAg
ICBzZXFsb2NrID0+IGxvX3NlcWxvY2sNCiAgICBzdGF0ZWlkID0+IGxvX3N0YXRlaWQNCiAgICBw
bmZzX2xheW91dF9zdGF0ZSA9PiBsb19zdGF0ZQ0KICAgIHBuZnNfd3JpdGVfYmVnaW5fcG9zID0+
IGxvX3dyaXRlX2JlZ2luDQogICAgcG5mc193cml0ZV9lbmRfcG9zID0+IGxvX3dyaXRlX2VuZA0K
DQoqKioqKioqKioNCmluY2x1ZGUvbGludXgvcG5mc194ZHIuaA0KDQpOT1RFOiBjb25zaWRlciBy
ZW1vdmluZyBhbmQgYWRkaW5nIHRvIGluY2x1ZGUvbGludXgvbmZzX3hkci5oIHdoZXJlIHRoZSBv
dGhlcg0KbmZzdjQuMSB4ZHIgc3RydWN0cyBhcmUgZGVjbGFyZWQuDQoNCnN0cnVjdCBuZnM0X3Bu
ZnNfbGF5b3V0ID0+IHJlbW92ZSwgaW5saW5lIGluIG5mczRfbGF5b3V0Z2V0X2FyZ3MuDQoNCnN0
cnVjdCBuZnM0X3BuZnNfbGF5b3V0X3NlZ21lbnQgPT4gcG5mc19sYXlvdXRfcmFuZ2UNCg0Kc3Ry
dWN0IG5mczRfcG5mc19sYXlvdXRnZXRfYXJnID0+IG5mczRfbGF5b3V0Z2V0X2FyZ3MNCmZpZWxk
czoNCiAgICBsc2VnID0+IHJhbmdlDQogICAgbGF5b3V0OiByZW1vdmUuIGlubGluZSB3aXRoOg0K
CWFkZDogbGF5b3V0X2xlbg0KICAgICAgICBhZGQ6IGxheW91dF9idWYNCg0Kc3RydWN0IG5mczRf
cG5mc19sYXlvdXRnZXRfcmVzID0+IG5mczRfbGF5b3V0Z2V0X3Jlcw0KZmllbGRzOg0KICAgIGxz
ZWcgPT4gcmFuZ2UNCg0Kc3RydWN0IG5mczRfcG5mc19sYXlvdXRnZXQgPT4gbmZzNF9sYXlvdXRn
ZXQNCg0Kc3RydWN0IHBuZnNfbGF5b3V0Y29tbWl0X2FyZyA9PiBuZnM0X2xheW91dGNvbW1pdF9h
cmdzDQpmaWVsZHM6DQogICAgbHNlZyA9PiByYW5nZQ0KDQpzdHJ1Y3QgcG5mc19sYXlvdXRjb21t
aXRfcmVzID0+IG5mczRfbGF5b3V0Y29tbWl0X3Jlcw0KDQpzdHJ1Y3QgcG5mc19sYXlvdXRjb21t
aXRfZGF0YSA9PiBuZnM0X2xheW91dGNvbW1pdF9kYXRhDQoNCnN0cnVjdCBuZnM0X3BuZnNfbGF5
b3V0cmV0dXJuX2FyZyA9PiBuZnM0X2xheW91dHJldHVybl9hcmdzDQpmaWVsZHM6DQogICAgbHNl
ZyA9PiByYW5nZQ0KDQpzdHJ1Y3QgbmZzNF9wbmZzX2xheW91dHJldHVybl9yZXMgPT4gbmZzNF9s
YXlvdXRyZXR1cm5fcmVzDQoNCnN0cnVjdCBuZnM0X3BuZnNfbGF5b3V0cmV0dXJuID0+IG5mczRf
bGF5b3V0cmV0dXJuDQoNCnN0cnVjdCBuZnM0X3BuZnNfZ2V0ZGV2aWNlaW5mb19hcmcgPT4gbmZz
NF9nZXRkZXZpY2VpbmZvX2FyZ3MNCg0Kc3RydWN0IG5mczRfcG5mc19nZXRkZXZpY2VpbmZvX3Jl
cyA9PiBuZnM0X2dldGRldmljZWluZm9fcmVzDQoNCioqKioqKioqKg0KaW5jbHVkZS9saW51eC9u
ZnM0LmgNCg0KTkZTUFJPQzRfQ0xOVF9QTkZTX0xBWU9VVEdFVCA9PiBORlNQUk9DNF9DTE5UX0xB
WU9VVEdFVA0KTkZTUFJPQzRfQ0xOVF9QTkZTX0xBWU9VVENPTU1JVCA9PiBORlNQUk9DNF9DTE5U
X0xBWU9VVENPTU1JVA0KTkZTUFJPQzRfQ0xOVF9QTkZTX0xBWU9VVFJFVFVSTiA9PiBORlNQUk9D
NF9DTE5UX0xBWU9VVFJFVFVSTg0KTkZTUFJPQzRfQ0xOVF9QTkZTX0dFVERFVklDRUlORk8gPT4g
TkZTUFJPQzRfQ0xOVF9HRVRERVZJQ0VJTkZPDQoNCioqKioqKioqKg0KDQpmcy9uZnMvbmZzNHBy
b2MuYw0KDQpuZnM0X3BuZnNfbGF5b3V0Z2V0X3ByZXBhcmUgPT4gbmZzNF9sYXlvdXRnZXRfcHJl
cGFyZQ0KbmZzNF9wbmZzX2xheW91dGdldF9kb25lID0+IG5mczRfbGF5b3V0Z2V0X2RvbmUNCm5m
czRfcG5mc19sYXlvdXRnZXRfcmVsZWFzZSA9PiBuZnM0X2xheW91dGdldF9yZWxlYXNlDQoNCl9w
bmZzNF9wcm9jX2xheW91dGdldCA9PiBfbmZzNF9wcm9jX2xheW91dGdldA0KcG5mczRfcHJvY19s
YXlvdXRnZXQgPT4gbmZzNF9wcm9jX2xheW91dGdldA0KDQoNCnBuZnNfbGF5b3V0Y29tbWl0X3By
ZXBhcmUgPT4gbmZzNF9sYXlvdXRjb21taXRfcHJlcGFyZQ0KcG5mc19sYXlvdXRjb21taXRfZG9u
ZSA9PiBuZnM0X2xheW91dGNvbW1pdF9kb25lDQpwbmZzX2xheW91dGNvbW1pdF9yZWxlYXNlID0+
IG5mczRfbGF5b3V0Y29tbWl0X3JlbGVhc2UNCg0KX3BuZnM0X3Byb2NfbGF5b3V0Y29tbWl0ID0+
IF9uZnM0X3Byb2NfbGF5b3V0Y29tbWl0DQpwbmZzNF9wcm9jX2xheW91dGNvbW1pdCA9PiBuZnM0
X3Byb2NfbGF5b3V0Y29tbWl0DQoNCm5mczRfcG5mc19sYXlvdXRyZXR1cm5fcHJlcGFyZSA9PiBu
ZnM0X2xheW91dHJldHVybl9wcmVwYXJlDQpuZnM0X3BuZnNfbGF5b3V0cmV0dXJuX2RvbmUgPT4g
bmZzNF9sYXlvdXRyZXR1cm5fZG9uZQ0KbmZzNF9wbmZzX2xheW91dHJldHVybl9yZWxlYXNlID0+
IG5mczRfbGF5b3V0cmV0dXJuX3JlbGVhc2UNCg0KX3BuZnM0X3Byb2NfbGF5b3V0cmV0dXJuID0+
IF9uZnM0X3Byb2NfbGF5b3V0cmV0dXJuDQpwbmZzNF9wcm9jX2xheW91dHJldHVybiA9PiBuZnM0
X3Byb2NfbGF5b3V0cmV0dXJuDQoNCm5mczRfcG5mc19nZXRkZXZpY2VpbmZvID0+IG5mczRfcHJv
Y19nZXRkZXZpY2VpbmZvDQo=

--_002_DD09EF29A7044F17B917C01051355CA3netappcom_--
