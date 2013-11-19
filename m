Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56565 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939Ab3KSVuD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Nov 2013 16:50:03 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session
 errors
Date: Tue, 19 Nov 2013 21:49:58 +0000
Message-ID: <1384897797.45997.1.camel@leira.trondhjem.org>
References: <1384551376-8734-1-git-send-email-andros@netapp.com>
In-Reply-To: <1384551376-8734-1-git-send-email-andros@netapp.com>
Content-Type: multipart/mixed;
	boundary="_002_1384897797459971camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_1384897797459971camelleiratrondhjemorg_
Content-Type: text/plain; charset="utf-7"
Content-ID: <58343AF993D973488D92138258725D35@hq.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-15 at 16:36 -0500, andros+AEA-netapp.com wrote:
+AD4- From: Andy Adamson +ADw-andros+AEA-netapp.com+AD4-
+AD4-=20
+AD4- When the state manager is processing the NFS4CLNT+AF8-DELEGRETURN fla=
g, session
+AD4- draining is off, but DELEGRETURN can still get a session error.
+AD4- The async handler calls nfs4+AF8-schedule+AF8-session+AF8-recovery re=
turns -EAGAIN, and
+AD4- the DELEGRETURN done then restarts the RPC task in the prepare state.
+AD4- With the state manager still processing the NFS4CLNT+AF8-DELEGRETURN =
flag with
+AD4- session draining off, these DELEGRETURNs will cycle with errors filli=
ng up the
+AD4- session slots.
+AD4-=20
+AD4- This prevents OPEN reclaims (from nfs+AF8-delegation+AF8-claim+AF8-op=
ens) required by the
+AD4- NFS4CLNT+AF8-DELEGRETURN state manager processing from completing, ha=
nging the
+AD4- state manager in the +AF8AXw-rpc+AF8-wait+AF8-for+AF8-completion+AF8-=
task in nfs4+AF8-run+AF8-open+AF8-task
+AD4- as seen in this kernel thread dump:
+AD4-=20

Hi Andy,

There is a second patch that goes with this problem. Please see the
following attachment.

Cheers
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_1384897797459971camelleiratrondhjemorg_
Content-Type: text/x-patch;
	name="0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch"
Content-Description: 0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch
Content-Disposition: attachment;
	filename="0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch";
	size=1398; creation-date="Tue, 19 Nov 2013 21:49:58 GMT";
	modification-date="Tue, 19 Nov 2013 21:49:58 GMT"
Content-ID: <1F0AACFC30A4EA4481BEB628E5BC9DEA@hq.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSAyMGE0MDY3MjQzZjgxYzE0MTdiZjYyZWNlYTc2OTdiNzk5MDE5MjZmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFR1ZSwgMTkgTm92IDIwMTMgMTY6MzQ6MTQgLTA1MDANClN1YmplY3Q6
IFtQQVRDSF0gTkZTdjQ6IFVwZGF0ZSBsaXN0IG9mIGlycmVjb3ZlcmFibGUgZXJyb3JzIG9uIERF
TEVHUkVUVVJODQoNCklmIHRoZSBERUxFR1JFVFVSTiBlcnJvcnMgb3V0IHdpdGggc29tZXRoaW5n
IGxpa2UgTkZTNEVSUl9CQURfU1RBVEVJRA0KdGhlbiB0aGVyZSBpcyBubyByZWNvdmVyeSBwb3Nz
aWJsZS4NCg0KQWxzbywgdGhlIGNsaWVudCBtdXN0IG5vdCBhc3N1bWUgdGhhdCB0aGUgTkZTdjQg
bGVhc2UgaGFzIGJlZW4gcmVuZXdlZA0Kd2hlbiBpdCBzZWVzIGFuIGVycm9yIG9uIERFTEVHUkVU
VVJOLg0KDQpTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPFRyb25kLk15a2xlYnVzdEBu
ZXRhcHAuY29tPg0KQ2M6IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcNCi0tLQ0KIGZzL25mcy9uZnM0
cHJvYy5jIHwgOCArKysrKystLQ0KIDEgZmlsZSBjaGFuZ2VkLCA2IGluc2VydGlvbnMoKyksIDIg
ZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9u
ZnM0cHJvYy5jDQppbmRleCAxZjRlZGZiYjRhNzAuLmFhMTZhMjJhZDM0OSAxMDA2NDQNCi0tLSBh
L2ZzL25mcy9uZnM0cHJvYy5jDQorKysgYi9mcy9uZnMvbmZzNHByb2MuYw0KQEAgLTQ5ODgsMTAg
KzQ5ODgsMTQgQEAgc3RhdGljIHZvaWQgbmZzNF9kZWxlZ3JldHVybl9kb25lKHN0cnVjdCBycGNf
dGFzayAqdGFzaywgdm9pZCAqY2FsbGRhdGEpDQogDQogCXRyYWNlX25mczRfZGVsZWdyZXR1cm5f
ZXhpdCgmZGF0YS0+YXJncywgJmRhdGEtPnJlcywgdGFzay0+dGtfc3RhdHVzKTsNCiAJc3dpdGNo
ICh0YXNrLT50a19zdGF0dXMpIHsNCi0JY2FzZSAtTkZTNEVSUl9TVEFMRV9TVEFURUlEOg0KLQlj
YXNlIC1ORlM0RVJSX0VYUElSRUQ6DQogCWNhc2UgMDoNCiAJCXJlbmV3X2xlYXNlKGRhdGEtPnJl
cy5zZXJ2ZXIsIGRhdGEtPnRpbWVzdGFtcCk7DQorCWNhc2UgLU5GUzRFUlJfQURNSU5fUkVWT0tF
RDoNCisJY2FzZSAtTkZTNEVSUl9ERUxFR19SRVZPS0VEOg0KKwljYXNlIC1ORlM0RVJSX0JBRF9T
VEFURUlEOg0KKwljYXNlIC1ORlM0RVJSX09MRF9TVEFURUlEOg0KKwljYXNlIC1ORlM0RVJSX1NU
QUxFX1NUQVRFSUQ6DQorCWNhc2UgLU5GUzRFUlJfRVhQSVJFRDoNCiAJCWJyZWFrOw0KIAlkZWZh
dWx0Og0KIAkJaWYgKG5mczRfYXN5bmNfaGFuZGxlX2Vycm9yKHRhc2ssIGRhdGEtPnJlcy5zZXJ2
ZXIsIE5VTEwpID09DQotLSANCjEuOC4zLjENCg0K

--_002_1384897797459971camelleiratrondhjemorg_--
