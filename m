Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13948 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754681Ab3ACX07 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 18:26:59 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Tejun Heo <tj@kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Date: Thu, 3 Jan 2013 23:26:56 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911988B37@SACEXCMBX04-PRD.hq.netapp.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121221230849.GB29739@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121221232609.GC29739@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121221234530.GA30048@fieldses.org>
	 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
	 <20130103201120.GA2096@fieldses.org> <20130103220814.GB2753@mtj.dyndns.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9119886EE@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130103222639.GE2753@mtj.dyndns.org>
	 <1357254692.55285.33.camel@lade.trondhjem.org>
In-Reply-To: <1357254692.55285.33.camel@lade.trondhjem.org>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988B37SACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988B37SACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <A0FF37CE473B0847A464F97EE2E54E06@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-01-03 at 18:11 -0500, Trond Myklebust wrote:
+AD4- On Thu, 2013-01-03 at 17:26 -0500, Tejun Heo wrote:
+AD4- +AD4- Ooh, BTW, there was a bug where workqueue code created a false
+AD4- +AD4- dependency between two work items.  Workqueue currently conside=
rs two
+AD4- +AD4- work items to be the same if they're on the same address and wo=
n't
+AD4- +AD4- execute them concurrently - ie. it makes a work item which is q=
ueued
+AD4- +AD4- again while being executed wait for the previous execution to
+AD4- +AD4- complete.
+AD4- +AD4-=20
+AD4- +AD4- If a work function frees the work item, and then waits for an e=
vent
+AD4- +AD4- which should be performed by another work item and +ACo-that+AC=
o- work item
+AD4- +AD4- recycles the freed work item, it can create a false dependency =
loop.
+AD4- +AD4- There really is no reliable way to detect this short of verifyi=
ng
+AD4- +AD4- every memory free.  A patch is queued to make such occurrences =
less
+AD4- +AD4- likely (work functions should also match for two work items con=
sidered
+AD4- +AD4- the same), but if you're seeing this, the best thing to do is f=
reeing
+AD4- +AD4- the work item at the end of the work function.
+AD4-=20
+AD4- That's interesting... I wonder if we may have been hitting that issue=
.
+AD4-=20
+AD4- From what I can see, we do actually free the write RPC task (and henc=
e
+AD4- the work+AF8-struct) before we call the asynchronous unlink completio=
n...
+AD4-=20
+AD4- Dros, can you see if reverting commit
+AD4- 324d003b0cd82151adbaecefef57b73f7959a469 +- commit=20
+AD4- 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9 and then applying the attach=
ed
+AD4- patch also fixes the hang on a pristine 3.7.x kernel?

Actually, we probably also need to look at rpc+AF8-free+AF8-task, so the
following patch, instead...

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988B37SACEXCMBX04PRDh_
Content-Type: text/x-patch; name="gnurr2.dif"
Content-Description: gnurr2.dif
Content-Disposition: attachment; filename="gnurr2.dif"; size=2061;
	creation-date="Thu, 03 Jan 2013 23:26:56 GMT";
	modification-date="Thu, 03 Jan 2013 23:26:56 GMT"
Content-ID: <BF52578E4B6F054490446459FE02B2A6@tahoe.netapp.com>
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2ZzL25mcy9yZWFkLmMgYi9mcy9uZnMvcmVhZC5jDQppbmRleCBiNmJkYjE4
Li40MDBmN2VjIDEwMDY0NA0KLS0tIGEvZnMvbmZzL3JlYWQuYw0KKysrIGIvZnMvbmZzL3JlYWQu
Yw0KQEAgLTkxLDEyICs5MSwxMyBAQCB2b2lkIG5mc19yZWFkZGF0YV9yZWxlYXNlKHN0cnVjdCBu
ZnNfcmVhZF9kYXRhICpyZGF0YSkNCiAJcHV0X25mc19vcGVuX2NvbnRleHQocmRhdGEtPmFyZ3Mu
Y29udGV4dCk7DQogCWlmIChyZGF0YS0+cGFnZXMucGFnZXZlYyAhPSByZGF0YS0+cGFnZXMucGFn
ZV9hcnJheSkNCiAJCWtmcmVlKHJkYXRhLT5wYWdlcy5wYWdldmVjKTsNCi0JaWYgKHJkYXRhICE9
ICZyZWFkX2hlYWRlci0+cnBjX2RhdGEpDQotCQlrZnJlZShyZGF0YSk7DQotCWVsc2UNCisJaWYg
KHJkYXRhID09ICZyZWFkX2hlYWRlci0+cnBjX2RhdGEpIHsNCiAJCXJkYXRhLT5oZWFkZXIgPSBO
VUxMOw0KKwkJcmRhdGEgPSBOVUxMOw0KKwl9DQogCWlmIChhdG9taWNfZGVjX2FuZF90ZXN0KCZo
ZHItPnJlZmNudCkpDQogCQloZHItPmNvbXBsZXRpb25fb3BzLT5jb21wbGV0aW9uKGhkcik7DQor
CWtmcmVlKHJkYXRhKTsNCiB9DQogRVhQT1JUX1NZTUJPTF9HUEwobmZzX3JlYWRkYXRhX3JlbGVh
c2UpOw0KIA0KZGlmZiAtLWdpdCBhL2ZzL25mcy93cml0ZS5jIGIvZnMvbmZzL3dyaXRlLmMNCmlu
ZGV4IGI2NzNiZTMuLjQ1ZDkyNTAgMTAwNjQ0DQotLS0gYS9mcy9uZnMvd3JpdGUuYw0KKysrIGIv
ZnMvbmZzL3dyaXRlLmMNCkBAIC0xMjYsMTIgKzEyNiwxMyBAQCB2b2lkIG5mc193cml0ZWRhdGFf
cmVsZWFzZShzdHJ1Y3QgbmZzX3dyaXRlX2RhdGEgKndkYXRhKQ0KIAlwdXRfbmZzX29wZW5fY29u
dGV4dCh3ZGF0YS0+YXJncy5jb250ZXh0KTsNCiAJaWYgKHdkYXRhLT5wYWdlcy5wYWdldmVjICE9
IHdkYXRhLT5wYWdlcy5wYWdlX2FycmF5KQ0KIAkJa2ZyZWUod2RhdGEtPnBhZ2VzLnBhZ2V2ZWMp
Ow0KLQlpZiAod2RhdGEgIT0gJndyaXRlX2hlYWRlci0+cnBjX2RhdGEpDQotCQlrZnJlZSh3ZGF0
YSk7DQotCWVsc2UNCisJaWYgKHdkYXRhID09ICZ3cml0ZV9oZWFkZXItPnJwY19kYXRhKSB7DQog
CQl3ZGF0YS0+aGVhZGVyID0gTlVMTDsNCisJCXdkYXRhID0gTlVMTDsNCisJfQ0KIAlpZiAoYXRv
bWljX2RlY19hbmRfdGVzdCgmaGRyLT5yZWZjbnQpKQ0KIAkJaGRyLT5jb21wbGV0aW9uX29wcy0+
Y29tcGxldGlvbihoZHIpOw0KKwlrZnJlZSh3ZGF0YSk7DQogfQ0KIEVYUE9SVF9TWU1CT0xfR1BM
KG5mc193cml0ZWRhdGFfcmVsZWFzZSk7DQogDQpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9zY2hl
ZC5jIGIvbmV0L3N1bnJwYy9zY2hlZC5jDQppbmRleCBkMTdhNzA0Li41MDA0MDdhIDEwMDY0NA0K
LS0tIGEvbmV0L3N1bnJwYy9zY2hlZC5jDQorKysgYi9uZXQvc3VucnBjL3NjaGVkLmMNCkBAIC05
MzYsMTQgKzkzNiwxMyBAQCBzdHJ1Y3QgcnBjX3Rhc2sgKnJwY19uZXdfdGFzayhjb25zdCBzdHJ1
Y3QgcnBjX3Rhc2tfc2V0dXAgKnNldHVwX2RhdGEpDQogDQogc3RhdGljIHZvaWQgcnBjX2ZyZWVf
dGFzayhzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQogew0KLQljb25zdCBzdHJ1Y3QgcnBjX2NhbGxf
b3BzICp0a19vcHMgPSB0YXNrLT50a19vcHM7DQotCXZvaWQgKmNhbGxkYXRhID0gdGFzay0+dGtf
Y2FsbGRhdGE7DQorCXVuc2lnbmVkIHNob3J0IHRrX2ZsYWdzID0gdGFzay0+dGtfZmxhZ3M7DQog
DQotCWlmICh0YXNrLT50a19mbGFncyAmIFJQQ19UQVNLX0RZTkFNSUMpIHsNCisJcnBjX3JlbGVh
c2VfY2FsbGRhdGEodGFzay0+dGtfb3BzLCB0YXNrLT50a19jYWxsZGF0YSk7DQorCWlmICh0a19m
bGFncyAmIFJQQ19UQVNLX0RZTkFNSUMpIHsNCiAJCWRwcmludGsoIlJQQzogJTV1IGZyZWVpbmcg
dGFza1xuIiwgdGFzay0+dGtfcGlkKTsNCiAJCW1lbXBvb2xfZnJlZSh0YXNrLCBycGNfdGFza19t
ZW1wb29sKTsNCiAJfQ0KLQlycGNfcmVsZWFzZV9jYWxsZGF0YSh0a19vcHMsIGNhbGxkYXRhKTsN
CiB9DQogDQogc3RhdGljIHZvaWQgcnBjX2FzeW5jX3JlbGVhc2Uoc3RydWN0IHdvcmtfc3RydWN0
ICp3b3JrKQ0K

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988B37SACEXCMBX04PRDh_--
