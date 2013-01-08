Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:52166 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756134Ab3AHTo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2013 14:44:27 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Tue, 8 Jan 2013 19:44:25 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
	 <1357590561.28341.11.camel@lade.trondhjem.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911991BE9@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
	 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993608SACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993608SACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <ADCA64AC31941C41ABE5A6E068CBFD35@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-01-08 at 13:40 -0500, Chris Perl wrote:
+AD4- On Mon, Jan 07, 2013 at 05:00:47PM -0500, Chris Perl wrote:
+AD4- Anyway, it appears that on mount the rpc+AF8-tasks tk+AF8-client memb=
er is NULL
+AD4- and therefore the double dereference of task-+AD4-tk+AF8-xprt is what=
 blew
+AD4- things up.  I ammended the patch for this +AFs-1+AF0- and am testing =
it
+AD4- now.
+AD4-=20
+AD4- Thus far, I've still hit hangs, it just seems to take longer.  I'll h=
ave
+AD4- to dig in a bit further to see what's going on now.
+AD4-=20
+AD4- Is this CentOS 6.3 kernel this system too old for you guys to care?
+AD4- I.e. should I spend time reporting digging into and reporting problem=
s
+AD4- for this system as well or you only care about the fedora system?

My main interest is always the upstream (Linus) kernel, however the RPC
client in the CentOS 6.3 kernel does actually contain a lot of code that
was recently backported from upstream. As such, it is definitely of
interest to figure out corner case bugs so that we can compare to
upstream...

+AD4- I'll report back again when I have further info and after testing the
+AD4- fedora system.
+AD4-=20
+AD4- +AFs-1+AF0- linux-kernel-test.patch

I've attached the latest copy of the patch (v4). In addition to the
check for tk+AF8-client+ACEAPQ-NULL, it needed a couple of changes to deal =
with
the RCU code.

Cheers
   Trond

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993608SACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch"
Content-Description: 0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch
Content-Disposition: attachment;
	filename="0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch";
	size=2334; creation-date="Tue, 08 Jan 2013 19:44:25 GMT";
	modification-date="Tue, 08 Jan 2013 19:44:25 GMT"
Content-ID: <E29C9B767A47154FACE3D5FBC72179DF@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSA4N2VkNTAwMzZiODY2ZGIyZWMyYmExNmIyYTdhZWM0YTJiMGI3YzM5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IE1vbiwgNyBKYW4gMjAxMyAxNDozMDo0NiAtMDUwMA0KU3ViamVjdDog
W1BBVENIIHY0XSBTVU5SUEM6IEVuc3VyZSB3ZSByZWxlYXNlIHRoZSBzb2NrZXQgd3JpdGUgbG9j
ayBpZiB0aGUNCiBycGNfdGFzayBleGl0cyBlYXJseQ0KDQpJZiB0aGUgcnBjX3Rhc2sgZXhpdHMg
d2hpbGUgaG9sZGluZyB0aGUgc29ja2V0IHdyaXRlIGxvY2sgYmVmb3JlIGl0IGhhcw0KYWxsb2Nh
dGVkIGFuIHJwYyBzbG90LCB0aGVuIHRoZSB1c3VhbCBtZWNoYW5pc20gZm9yIHJlbGVhc2luZyB0
aGUgd3JpdGUNCmxvY2sgaW4geHBydF9yZWxlYXNlKCkgaXMgZGVmZWF0ZWQuDQoNClRoZSBwcm9i
bGVtIG9jY3VycyBpZiB0aGUgY2FsbCB0byB4cHJ0X2xvY2tfd3JpdGUoKSBpbml0aWFsbHkgZmFp
bHMsIHNvDQp0aGF0IHRoZSBycGNfdGFzayBpcyBwdXQgb24gdGhlIHhwcnQtPnNlbmRpbmcgd2Fp
dCBxdWV1ZS4gSWYgdGhlIHRhc2sNCmV4aXRzIGFmdGVyIGJlaW5nIGFzc2lnbmVkIHRoZSBsb2Nr
IGJ5IF9feHBydF9sb2NrX3dyaXRlX2Z1bmMsIGJ1dA0KYmVmb3JlIGl0IGhhcyByZXRyaWVkIHRo
ZSBjYWxsIHRvIHhwcnRfbG9ja19hbmRfYWxsb2Nfc2xvdCgpLCB0aGVuDQppdCBjYWxscyB4cHJ0
X3JlbGVhc2UoKSB3aGlsZSBob2xkaW5nIHRoZSB3cml0ZSBsb2NrLCBidXQgd2lsbA0KaW1tZWRp
YXRlbHkgZXhpdCBkdWUgdG8gdGhlIHRlc3QgZm9yIHRhc2stPnRrX3Jxc3RwICE9IE5VTEwuDQoN
ClJlcG9ydGVkLWJ5OiBDaHJpcyBQZXJsIDxjaHJpcy5wZXJsQGdtYWlsLmNvbT4NClNpZ25lZC1v
ZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+DQpDYzog
c3RhYmxlQHZnZXIua2VybmVsLm9yZyBbPj0gMy4xXQ0KLS0tDQogbmV0L3N1bnJwYy9zY2hlZC5j
IHwgIDMgKy0tDQogbmV0L3N1bnJwYy94cHJ0LmMgIHwgMTIgKysrKysrKysrKy0tDQogMiBmaWxl
cyBjaGFuZ2VkLCAxMSBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0KDQpkaWZmIC0tZ2l0
IGEvbmV0L3N1bnJwYy9zY2hlZC5jIGIvbmV0L3N1bnJwYy9zY2hlZC5jDQppbmRleCBiNDEzM2Jk
Li5iZmEzMTcxIDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy9zY2hlZC5jDQorKysgYi9uZXQvc3Vu
cnBjL3NjaGVkLmMNCkBAIC05NzIsOCArOTcyLDcgQEAgc3RhdGljIHZvaWQgcnBjX2FzeW5jX3Jl
bGVhc2Uoc3RydWN0IHdvcmtfc3RydWN0ICp3b3JrKQ0KIA0KIHN0YXRpYyB2b2lkIHJwY19yZWxl
YXNlX3Jlc291cmNlc190YXNrKHN0cnVjdCBycGNfdGFzayAqdGFzaykNCiB7DQotCWlmICh0YXNr
LT50a19ycXN0cCkNCi0JCXhwcnRfcmVsZWFzZSh0YXNrKTsNCisJeHBydF9yZWxlYXNlKHRhc2sp
Ow0KIAlpZiAodGFzay0+dGtfbXNnLnJwY19jcmVkKSB7DQogCQlwdXRfcnBjY3JlZCh0YXNrLT50
a19tc2cucnBjX2NyZWQpOw0KIAkJdGFzay0+dGtfbXNnLnJwY19jcmVkID0gTlVMTDsNCmRpZmYg
LS1naXQgYS9uZXQvc3VucnBjL3hwcnQuYyBiL25ldC9zdW5ycGMveHBydC5jDQppbmRleCBiZDQ2
MmE1Li4zMzgxMWRiIDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy94cHJ0LmMNCisrKyBiL25ldC9z
dW5ycGMveHBydC5jDQpAQCAtMTEzNiwxMCArMTEzNiwxOCBAQCBzdGF0aWMgdm9pZCB4cHJ0X3Jl
cXVlc3RfaW5pdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssIHN0cnVjdCBycGNfeHBydCAqeHBydCkN
CiB2b2lkIHhwcnRfcmVsZWFzZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQogew0KIAlzdHJ1Y3Qg
cnBjX3hwcnQJKnhwcnQ7DQotCXN0cnVjdCBycGNfcnFzdAkqcmVxOw0KKwlzdHJ1Y3QgcnBjX3Jx
c3QJKnJlcSA9IHRhc2stPnRrX3Jxc3RwOw0KIA0KLQlpZiAoIShyZXEgPSB0YXNrLT50a19ycXN0
cCkpDQorCWlmIChyZXEgPT0gTlVMTCkgew0KKwkJaWYgKHRhc2stPnRrX2NsaWVudCkgew0KKwkJ
CXJjdV9yZWFkX2xvY2soKTsNCisJCQl4cHJ0ID0gcmN1X2RlcmVmZXJlbmNlKHRhc2stPnRrX2Ns
aWVudC0+Y2xfeHBydCk7DQorCQkJaWYgKHhwcnQtPnNuZF90YXNrID09IHRhc2spDQorCQkJCXhw
cnRfcmVsZWFzZV93cml0ZSh4cHJ0LCB0YXNrKTsNCisJCQlyY3VfcmVhZF91bmxvY2soKTsNCisJ
CX0NCiAJCXJldHVybjsNCisJfQ0KIA0KIAl4cHJ0ID0gcmVxLT5ycV94cHJ0Ow0KIAlpZiAodGFz
ay0+dGtfb3BzLT5ycGNfY291bnRfc3RhdHMgIT0gTlVMTCkNCi0tIA0KMS43LjExLjcNCg0K

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993608SACEXCMBX04PRDh_--
