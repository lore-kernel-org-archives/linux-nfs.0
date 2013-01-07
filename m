Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53481 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844Ab3AGU3Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2013 15:29:25 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Mon, 7 Jan 2013 20:29:23 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911991BC0@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA911991BC0SACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911991BC0SACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <1CB151891DADF14E96686937FCE0D072@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-01-07 at 15:20 -0500, Chris Perl wrote:
+AD4- On Mon, Jan 07, 2013 at 07:50:10PM +-0000, Myklebust, Trond wrote:
+AD4- +AD4- Hi Chris,
+AD4- +AD4-=20
+AD4- +AD4- Excellent sleuthing+ACE- Given the thoroughness of your explana=
tion, I'm
+AD4- +AD4- pretty sure that the attached patch should fix the problem.
+AD4- +AD4-=20
+AD4- +AD4- Cheers
+AD4- +AD4-   Trond
+AD4- +AD4- --=20
+AD4- +AD4- Trond Myklebust
+AD4- +AD4- Linux NFS client maintainer
+AD4- +AD4-=20
+AD4- +AD4- NetApp
+AD4- +AD4- Trond.Myklebust+AEA-netapp.com
+AD4- +AD4- www.netapp.com
+AD4-=20
+AD4- +AD4- From ec8cbb4aff21cd0eac2c6f3fc4273ac72cdd91ef Mon Sep 17 00:00:=
00 2001
+AD4- +AD4- From: Trond Myklebust +ADw-Trond.Myklebust+AEA-netapp.com+AD4-
+AD4- +AD4- Date: Mon, 7 Jan 2013 14:30:46 -0500
+AD4- +AD4- Subject: +AFs-PATCH+AF0- SUNRPC: Ensure we release the socket w=
rite lock if the
+AD4- +AD4-  rpc+AF8-task exits early
+AD4- +AD4-=20
+AD4- +AD4- If the rpc+AF8-task exits while holding the socket write lock b=
efore it has
+AD4- +AD4- allocated an rpc slot, then the usual mechanism for releasing t=
he write
+AD4- +AD4- lock in xprt+AF8-release() is defeated.
+AD4- +AD4-=20
+AD4- +AD4- The problem occurs if the call to xprt+AF8-lock+AF8-write() ini=
tially fails, so
+AD4- +AD4- that the rpc+AF8-task is put on the xprt-+AD4-sending wait queu=
e. If the task
+AD4- +AD4- exits after being assigned the lock by +AF8AXw-xprt+AF8-lock+AF=
8-write+AF8-func, but
+AD4- +AD4- before it has retried the call to xprt+AF8-lock+AF8-and+AF8-all=
oc+AF8-slot(), then
+AD4- +AD4- it calls xprt+AF8-release() while holding the write lock, but w=
ill
+AD4- +AD4- immediately exit due to the test for task-+AD4-tk+AF8-rqstp +AC=
EAPQ- NULL.
+AD4- +AD4-=20
+AD4- +AD4- Reported-by: Chris Perl +ADw-chris.perl+AEA-gmail.com+AD4-
+AD4- +AD4- Signed-off-by: Trond Myklebust +ADw-Trond.Myklebust+AEA-netapp.=
com+AD4-
+AD4- +AD4- Cc: stable+AEA-vger.kernel.org +AFsAPgA9- 3.1+AF0-
+AD4- +AD4- ---
+AD4- +AD4-  net/sunrpc/xprt.c +AHw- 6 +-+-+-+---
+AD4- +AD4-  1 file changed, 4 insertions(+-), 2 deletions(-)
+AD4- +AD4-=20
+AD4- +AD4- diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
+AD4- +AD4- index bd462a5..6676457 100644
+AD4- +AD4- --- a/net/sunrpc/xprt.c
+AD4- +AD4- +-+-+- b/net/sunrpc/xprt.c
+AD4- +AD4- +AEAAQA- -1136,10 +-1136,12 +AEAAQA- static void xprt+AF8-reque=
st+AF8-init(struct rpc+AF8-task +ACo-task, struct rpc+AF8-xprt +ACo-xprt)
+AD4- +AD4-  void xprt+AF8-release(struct rpc+AF8-task +ACo-task)
+AD4- +AD4-  +AHs-
+AD4- +AD4-  	struct rpc+AF8-xprt	+ACo-xprt+ADs-
+AD4- +AD4- -	struct rpc+AF8-rqst	+ACo-req+ADs-
+AD4- +AD4- +-	struct rpc+AF8-rqst	+ACo-req +AD0- task-+AD4-tk+AF8-rqstp+AD=
s-
+AD4- +AD4- =20
+AD4- +AD4- -	if (+ACE-(req +AD0- task-+AD4-tk+AF8-rqstp))
+AD4- +AD4- +-	if (req +AD0APQ- NULL) +AHs-
+AD4- +AD4- +-		xprt+AF8-release+AF8-write(task-+AD4-tk+AF8-xprt, task)+ADs=
-
+AD4- +AD4-  		return+ADs-
+AD4- +AD4- +-	+AH0-
+AD4- +AD4- =20
+AD4- +AD4-  	xprt +AD0- req-+AD4-rq+AF8-xprt+ADs-
+AD4- +AD4-  	if (task-+AD4-tk+AF8-ops-+AD4-rpc+AF8-count+AF8-stats +ACEAPQ=
- NULL)
+AD4- +AD4- --=20
+AD4- +AD4- 1.7.11.7
+AD4- +AD4-=20
+AD4-=20
+AD4- Ah, I totally missed the call to +AGA-rpc+AF8-release+AF8-task' at th=
e bottom of the
+AD4- +AGAAXwBf-rpc+AF8-execute' loop (at least thats how I think we'd get =
to this function
+AD4- you're patching).
+AD4-=20
+AD4- But wouldn't we need to update the call site in
+AD4- +AGA-rpc+AF8-release+AF8-resources+AF8-task' as well?  It contains an=
 explicit check for
+AD4- +AGA-task-+AD4-tk+AF8-rqstp' being non null.

Ewww.... You're right: That's a wart that seems to have been copied and
pasted quite a few times.

Here is v2...
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911991BC0SACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch"
Content-Description: 0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch
Content-Disposition: attachment;
	filename="0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch";
	size=2165; creation-date="Mon, 07 Jan 2013 20:29:23 GMT";
	modification-date="Mon, 07 Jan 2013 20:29:23 GMT"
Content-ID: <58331E0C73D3F749A4FE4F7244768158@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSA0MGIwZWYyOGZkYTBiM2VjZjhlNGYzNTg0NmQ5YjlhNzY1ZGY0YzQxIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IE1vbiwgNyBKYW4gMjAxMyAxNDozMDo0NiAtMDUwMA0KU3ViamVjdDog
W1BBVENIIHYyXSBTVU5SUEM6IEVuc3VyZSB3ZSByZWxlYXNlIHRoZSBzb2NrZXQgd3JpdGUgbG9j
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
IHwgMyArLS0NCiBuZXQvc3VucnBjL3hwcnQuYyAgfCA2ICsrKystLQ0KIDIgZmlsZXMgY2hhbmdl
ZCwgNSBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0KDQpkaWZmIC0tZ2l0IGEvbmV0L3N1
bnJwYy9zY2hlZC5jIGIvbmV0L3N1bnJwYy9zY2hlZC5jDQppbmRleCBiNDEzM2JkLi5iZmEzMTcx
IDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy9zY2hlZC5jDQorKysgYi9uZXQvc3VucnBjL3NjaGVk
LmMNCkBAIC05NzIsOCArOTcyLDcgQEAgc3RhdGljIHZvaWQgcnBjX2FzeW5jX3JlbGVhc2Uoc3Ry
dWN0IHdvcmtfc3RydWN0ICp3b3JrKQ0KIA0KIHN0YXRpYyB2b2lkIHJwY19yZWxlYXNlX3Jlc291
cmNlc190YXNrKHN0cnVjdCBycGNfdGFzayAqdGFzaykNCiB7DQotCWlmICh0YXNrLT50a19ycXN0
cCkNCi0JCXhwcnRfcmVsZWFzZSh0YXNrKTsNCisJeHBydF9yZWxlYXNlKHRhc2spOw0KIAlpZiAo
dGFzay0+dGtfbXNnLnJwY19jcmVkKSB7DQogCQlwdXRfcnBjY3JlZCh0YXNrLT50a19tc2cucnBj
X2NyZWQpOw0KIAkJdGFzay0+dGtfbXNnLnJwY19jcmVkID0gTlVMTDsNCmRpZmYgLS1naXQgYS9u
ZXQvc3VucnBjL3hwcnQuYyBiL25ldC9zdW5ycGMveHBydC5jDQppbmRleCBiZDQ2MmE1Li42Njc2
NDU3IDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy94cHJ0LmMNCisrKyBiL25ldC9zdW5ycGMveHBy
dC5jDQpAQCAtMTEzNiwxMCArMTEzNiwxMiBAQCBzdGF0aWMgdm9pZCB4cHJ0X3JlcXVlc3RfaW5p
dChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssIHN0cnVjdCBycGNfeHBydCAqeHBydCkNCiB2b2lkIHhw
cnRfcmVsZWFzZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQogew0KIAlzdHJ1Y3QgcnBjX3hwcnQJ
KnhwcnQ7DQotCXN0cnVjdCBycGNfcnFzdAkqcmVxOw0KKwlzdHJ1Y3QgcnBjX3Jxc3QJKnJlcSA9
IHRhc2stPnRrX3Jxc3RwOw0KIA0KLQlpZiAoIShyZXEgPSB0YXNrLT50a19ycXN0cCkpDQorCWlm
IChyZXEgPT0gTlVMTCkgew0KKwkJeHBydF9yZWxlYXNlX3dyaXRlKHRhc2stPnRrX3hwcnQsIHRh
c2spOw0KIAkJcmV0dXJuOw0KKwl9DQogDQogCXhwcnQgPSByZXEtPnJxX3hwcnQ7DQogCWlmICh0
YXNrLT50a19vcHMtPnJwY19jb3VudF9zdGF0cyAhPSBOVUxMKQ0KLS0gDQoxLjcuMTEuNw0KDQo=

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911991BC0SACEXCMBX04PRDh_--
