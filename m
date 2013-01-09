Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:12483 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932537Ab3AIUxC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2013 15:53:02 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Wed, 9 Jan 2013 20:52:59 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9119956CC@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
	 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108212343.GC30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993B82@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
	 <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993F1B@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130109175503.GF30872@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130109175503.GF30872@nyc-qws-132.nyc.delacy.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119956CCSACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119956CCSACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <5F4E80B26EA19240B9730FB65DEFD835@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-01-09 at 12:55 -0500, Chris Perl wrote:
+AD4- +AD4- Hrm.  I guess I'm in over my head here. Apologoies if I'm just =
asking
+AD4- +AD4- silly bumbling questions.  You can start ignoring me at any tim=
e. :)
+AD4-=20
+AD4- I stared at the code for a while and more and now see why what I
+AD4- outlined is not possible.  Thanks for helping to clarify+ACE-
+AD4-=20
+AD4- I decided to pull your git repo and compile with HEAD at
+AD4- 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39 (linux-next as of this
+AD4- morning).  Using this kernel, I can no longer induce any hangs.
+AD4-=20
+AD4- Interestingly, I tried recompiling the CentOS 6.3 kernel with
+AD4- both the original patch (v4) and the last patch you sent about fixing
+AD4- priority queues.  With both of those in place, I still run into a
+AD4- problem.
+AD4-=20
+AD4- echo 0 +AD4- /proc/sys/sunrpc/rpc+AF8-debug after the hang shows (I l=
eft in the
+AD4- previous additional prints and added printing of the tasks pointer
+AD4- itself):
+AD4-=20
+AD4- +ADw-6+AD4-client: ffff88082896c200, xprt: ffff880829011000, snd+AF8-=
task: ffff880829a1aac0
+AD4- +ADw-6+AD4-client: ffff8808282b5600, xprt: ffff880829011000, snd+AF8-=
task: ffff880829a1aac0
+AD4- +ADw-6+AD4---task-- -pid- flgs status -client- --rqstp- -timeout ---o=
ps--
+AD4- +ADw-6+AD4-ffff88082a463180 22007 0080    -11 ffff8808282b5600   (nul=
l)        0 ffffffffa027b7a0 nfsv3 ACCESS a:call+AF8-reserveresult q:xprt+A=
F8-sending
+AD4- +ADw-6+AD4-client: ffff88082838cc00, xprt: ffff88082b7c5800, snd+AF8-=
task:   (null)
+AD4- +ADw-6+AD4-client: ffff8808283db400, xprt: ffff88082b7c5800, snd+AF8-=
task:   (null)
+AD4- +ADw-6+AD4-client: ffff8808283db200, xprt: ffff880829011000, snd+AF8-=
task: ffff880829a1aac0
+AD4-=20
+AD4- Any thoughts about other patches that might affect this?

Hmm... The only one that springs to mind is this one (see attachment)
and then the 'connect' fixes that you helped us with previously.

Cheers
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119956CCSACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-SUNRPC-Ensure-that-we-free-the-rpc_task-after-cleanu.patch"
Content-Description: 0001-SUNRPC-Ensure-that-we-free-the-rpc_task-after-cleanu.patch
Content-Disposition: attachment;
	filename="0001-SUNRPC-Ensure-that-we-free-the-rpc_task-after-cleanu.patch";
	size=2422; creation-date="Wed, 09 Jan 2013 20:52:58 GMT";
	modification-date="Wed, 09 Jan 2013 20:52:58 GMT"
Content-ID: <252DF2FFA624E0418F14913AE1A8D245@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSBjNjU2N2VkMTQwMmM1NWUxOWIwMTJlNjZhODM5OGJhZWMyYTcyNmYzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IEZyaSwgNCBKYW4gMjAxMyAxMjoyMzoyMSAtMDUwMA0KU3ViamVjdDog
W1BBVENIXSBTVU5SUEM6IEVuc3VyZSB0aGF0IHdlIGZyZWUgdGhlIHJwY190YXNrIGFmdGVyIGNs
ZWFudXBzIGFyZQ0KIGRvbmUNCg0KVGhpcyBwYXRjaCBlbnN1cmVzIHRoYXQgd2UgZnJlZSB0aGUg
cnBjX3Rhc2sgYWZ0ZXIgdGhlIGNsZWFudXAgY2FsbGJhY2tzDQphcmUgZG9uZSBpbiBvcmRlciB0
byBhdm9pZCBhIGRlYWRsb2NrIHByb2JsZW0gdGhhdCBjYW4gYmUgdHJpZ2dlcmVkIGlmDQp0aGUg
Y2FsbGJhY2sgbmVlZHMgdG8gd2FpdCBmb3IgYW5vdGhlciB3b3JrcXVldWUgaXRlbSB0byBjb21w
bGV0ZS4NCg0KU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbT4NCkNjOiBXZXN0b24gQW5kcm9zIEFkYW1zb24gPGRyb3NAbmV0YXBwLmNvbT4N
CkNjOiBUZWp1biBIZW8gPHRqQGtlcm5lbC5vcmc+DQpDYzogQnJ1Y2UgRmllbGRzIDxiZmllbGRz
QGZpZWxkc2VzLm9yZz4NCkNjOiBzdGFibGVAdmdlci5rZXJuZWwub3JnDQotLS0NCiBuZXQvc3Vu
cnBjL3NjaGVkLmMgfCAyNyArKysrKysrKysrKysrKysrKysrKysrKy0tLS0NCiAxIGZpbGUgY2hh
bmdlZCwgMjMgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL25l
dC9zdW5ycGMvc2NoZWQuYyBiL25ldC9zdW5ycGMvc2NoZWQuYw0KaW5kZXggZDE3YTcwNC4uYjQx
MzNiZCAxMDA2NDQNCi0tLSBhL25ldC9zdW5ycGMvc2NoZWQuYw0KKysrIGIvbmV0L3N1bnJwYy9z
Y2hlZC5jDQpAQCAtOTM0LDE2ICs5MzQsMzUgQEAgc3RydWN0IHJwY190YXNrICpycGNfbmV3X3Rh
c2soY29uc3Qgc3RydWN0IHJwY190YXNrX3NldHVwICpzZXR1cF9kYXRhKQ0KIAlyZXR1cm4gdGFz
azsNCiB9DQogDQorLyoNCisgKiBycGNfZnJlZV90YXNrIC0gcmVsZWFzZSBycGMgdGFzayBhbmQg
cGVyZm9ybSBjbGVhbnVwcw0KKyAqDQorICogTm90ZSB0aGF0IHdlIGZyZWUgdXAgdGhlIHJwY190
YXNrIF9hZnRlcl8gcnBjX3JlbGVhc2VfY2FsbGRhdGEoKQ0KKyAqIGluIG9yZGVyIHRvIHdvcmsg
YXJvdW5kIGEgd29ya3F1ZXVlIGRlcGVuZGVuY3kgaXNzdWUuDQorICoNCisgKiBUZWp1biBIZW8g
c3RhdGVzOg0KKyAqICJXb3JrcXVldWUgY3VycmVudGx5IGNvbnNpZGVycyB0d28gd29yayBpdGVt
cyB0byBiZSB0aGUgc2FtZSBpZiB0aGV5J3JlDQorICogb24gdGhlIHNhbWUgYWRkcmVzcyBhbmQg
d29uJ3QgZXhlY3V0ZSB0aGVtIGNvbmN1cnJlbnRseSAtIGllLiBpdA0KKyAqIG1ha2VzIGEgd29y
ayBpdGVtIHdoaWNoIGlzIHF1ZXVlZCBhZ2FpbiB3aGlsZSBiZWluZyBleGVjdXRlZCB3YWl0DQor
ICogZm9yIHRoZSBwcmV2aW91cyBleGVjdXRpb24gdG8gY29tcGxldGUuDQorICoNCisgKiBJZiBh
IHdvcmsgZnVuY3Rpb24gZnJlZXMgdGhlIHdvcmsgaXRlbSwgYW5kIHRoZW4gd2FpdHMgZm9yIGFu
IGV2ZW50DQorICogd2hpY2ggc2hvdWxkIGJlIHBlcmZvcm1lZCBieSBhbm90aGVyIHdvcmsgaXRl
bSBhbmQgKnRoYXQqIHdvcmsgaXRlbQ0KKyAqIHJlY3ljbGVzIHRoZSBmcmVlZCB3b3JrIGl0ZW0s
IGl0IGNhbiBjcmVhdGUgYSBmYWxzZSBkZXBlbmRlbmN5IGxvb3AuDQorICogVGhlcmUgcmVhbGx5
IGlzIG5vIHJlbGlhYmxlIHdheSB0byBkZXRlY3QgdGhpcyBzaG9ydCBvZiB2ZXJpZnlpbmcNCisg
KiBldmVyeSBtZW1vcnkgZnJlZS4iDQorICoNCisgKi8NCiBzdGF0aWMgdm9pZCBycGNfZnJlZV90
YXNrKHN0cnVjdCBycGNfdGFzayAqdGFzaykNCiB7DQotCWNvbnN0IHN0cnVjdCBycGNfY2FsbF9v
cHMgKnRrX29wcyA9IHRhc2stPnRrX29wczsNCi0Jdm9pZCAqY2FsbGRhdGEgPSB0YXNrLT50a19j
YWxsZGF0YTsNCisJdW5zaWduZWQgc2hvcnQgdGtfZmxhZ3MgPSB0YXNrLT50a19mbGFnczsNCisN
CisJcnBjX3JlbGVhc2VfY2FsbGRhdGEodGFzay0+dGtfb3BzLCB0YXNrLT50a19jYWxsZGF0YSk7
DQogDQotCWlmICh0YXNrLT50a19mbGFncyAmIFJQQ19UQVNLX0RZTkFNSUMpIHsNCisJaWYgKHRr
X2ZsYWdzICYgUlBDX1RBU0tfRFlOQU1JQykgew0KIAkJZHByaW50aygiUlBDOiAlNXUgZnJlZWlu
ZyB0YXNrXG4iLCB0YXNrLT50a19waWQpOw0KIAkJbWVtcG9vbF9mcmVlKHRhc2ssIHJwY190YXNr
X21lbXBvb2wpOw0KIAl9DQotCXJwY19yZWxlYXNlX2NhbGxkYXRhKHRrX29wcywgY2FsbGRhdGEp
Ow0KIH0NCiANCiBzdGF0aWMgdm9pZCBycGNfYXN5bmNfcmVsZWFzZShzdHJ1Y3Qgd29ya19zdHJ1
Y3QgKndvcmspDQotLSANCjEuNy4xMS43DQoNCg==

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119956CCSACEXCMBX04PRDh_--
