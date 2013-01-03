Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:52302 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab3ACXLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 18:11:34 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Tejun Heo <tj@kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Date: Thu, 3 Jan 2013 23:11:33 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911988A27@SACEXCMBX04-PRD.hq.netapp.com>
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
In-Reply-To: <20130103222639.GE2753@mtj.dyndns.org>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988A27SACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988A27SACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <978C820A87F12C45A7344F7FDDB65B5E@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-01-03 at 17:26 -0500, Tejun Heo wrote:
+AD4- Hello, Trond.
+AD4-=20
+AD4- On Thu, Jan 03, 2013 at 10:12:32PM +-0000, Myklebust, Trond wrote:
+AD4- +AD4- +AD4- The analysis is likely completely wrong, so please don't =
go off doing
+AD4- +AD4- +AD4- something unnecessary.  Please take look at what's causin=
g the
+AD4- +AD4- +AD4- deadlocks again.
+AD4- +AD4-=20
+AD4- +AD4- The analysis is a no-brainer:
+AD4- +AD4- We see a deadlock due to one work item waiting for completion o=
f another
+AD4- +AD4- work item that is queued on the same CPU. There is no other dep=
endency
+AD4- +AD4- between the two work items.
+AD4-=20
+AD4- What do you mean +ACI-waiting for completion of+ACI-?  Is one flushin=
g the
+AD4- other?  Or is one waiting for the other to take certain action?  How
+AD4- are the two work items related?  Are they queued on the same
+AD4- workqueue?  Can you create a minimal repro case of the observed
+AD4- deadlock?

The two work items are running on different work queues. One is running
on the nfsiod work queue, and is waiting for the other to complete on
the rpciod work queue. Basically, the nfsiod work item is trying to shut
down an RPC session, and it is waiting for each outstanding RPC call to
finish running a clean-up routine.

We can't call flush+AF8-work(), since we don't have a way to pin the
work+AF8-struct for any long period of time, so we queue all the RPC calls
up, then sleep on a global wait queue for 1 second or until the last RPC
call wakes us up (see rpc+AF8-shutdown+AF8-client()).

In the deadlock scenario, it looks as if one (or more) of the RPC calls
are getting queued on the same CPU (but on the rpciod workqueue) as the
shutdown process (running on nfsiod).


+AD4- Ooh, BTW, there was a bug where workqueue code created a false
+AD4- dependency between two work items.  Workqueue currently considers two
+AD4- work items to be the same if they're on the same address and won't
+AD4- execute them concurrently - ie. it makes a work item which is queued
+AD4- again while being executed wait for the previous execution to
+AD4- complete.
+AD4-=20
+AD4- If a work function frees the work item, and then waits for an event
+AD4- which should be performed by another work item and +ACo-that+ACo- wor=
k item
+AD4- recycles the freed work item, it can create a false dependency loop.
+AD4- There really is no reliable way to detect this short of verifying
+AD4- every memory free.  A patch is queued to make such occurrences less
+AD4- likely (work functions should also match for two work items considere=
d
+AD4- the same), but if you're seeing this, the best thing to do is freeing
+AD4- the work item at the end of the work function.

That's interesting... I wonder if we may have been hitting that issue.

>From what I can see, we do actually free the write RPC task (and hence
the work+AF8-struct) before we call the asynchronous unlink completion...

Dros, can you see if reverting commit
324d003b0cd82151adbaecefef57b73f7959a469 +- commit=20
168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9 and then applying the attached
patch also fixes the hang on a pristine 3.7.x kernel?

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988A27SACEXCMBX04PRDh_
Content-Type: text/x-patch; name="gnurr.dif"
Content-Description: gnurr.dif
Content-Disposition: attachment; filename="gnurr.dif"; size=1283;
	creation-date="Thu, 03 Jan 2013 23:11:32 GMT";
	modification-date="Thu, 03 Jan 2013 23:11:32 GMT"
Content-ID: <407A21128E533B4BA2DD9A5CCF24CFC1@tahoe.netapp.com>
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
KG5mc193cml0ZWRhdGFfcmVsZWFzZSk7DQogDQo=

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911988A27SACEXCMBX04PRDh_--
