Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17723 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754305Ab3AHXLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2013 18:11:11 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Tue, 8 Jan 2013 23:10:58 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911993F1B@SACEXCMBX04-PRD.hq.netapp.com>
References: <1357590561.28341.11.camel@lade.trondhjem.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911991BE9@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
	 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108212343.GC30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993B82@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108221651.GD30872@nyc-qws-132.nyc.delacy.com>
	 <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130108221921.GE30872@nyc-qws-132.nyc.delacy.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993F1BSACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993F1BSACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <B7BDA9CB319EE44E9DBC83D726A498C7@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-01-08 at 17:19 -0500, Chris Perl wrote:
+AD4- On Tue, Jan 08, 2013 at 05:16:51PM -0500, Chris Perl wrote:
+AD4- +AD4- +AD4- The lock is associated with the rpc+AF8-task. Threads can=
 normally only
+AD4- +AD4- +AD4- access an rpc+AF8-task when it is on a wait queue (while =
holding the wait
+AD4- +AD4- +AD4- queue lock) unless they are given ownership of the rpc+AF=
8-task.
+AD4- +AD4- +AD4-=20
+AD4- +AD4- +AD4- IOW: the scenario you describe should not be possible, si=
nce it relies
+AD4- +AD4- +AD4- on thread 1 assigning the lock to the rpc+AF8-task after =
it has been removed
+AD4- +AD4- +AD4- from the wait queue.
+AD4- +AD4-=20
+AD4- +AD4- Hrm.  I guess I'm in over my head here. Apologoies if I'm just =
asking
+AD4- +AD4- silly bumbling questions.  You can start ignoring me at any tim=
e. :)
+AD4- +AD4-=20
+AD4- +AD4- I was talking about setting (or leaving set) the XPRT+AF8-LOCKE=
D bit in
+AD4- +AD4- rpc+AF8-xprt-+AD4-state.  By +ACI-assigning the lock+ACI- I rea=
lly just mean that thread
+AD4- +AD4- 1 leaves XPRT+AF8-LOCKED set in rpc+AF8-xprt-+AD4-state and set=
s rpc+AF8-xprt-+AD4-snd+AF8-task
+AD4- +AD4- to thread 2.
+AD4- +AD4-=20
+AD4- +AD4- +AD4- If you are recompiling the kernel, perhaps you can also a=
dd in a patch
+AD4- +AD4- +AD4- to rpc+AF8-show+AF8-tasks() to display the current value =
of
+AD4- +AD4- +AD4- clnt-+AD4-cl+AF8-xprt-+AD4-snd+AF8-task?
+AD4- +AD4-=20
+AD4- +AD4- Sure.  This is what 'echo 0 +AD4- /proc/sys/sunrpc/rpc+AF8-debu=
g' shows after
+AD4- +AD4- the hang (with my extra prints):
+AD4- +AD4-=20
+AD4- +AD4- +ACM- cat /proc/kmsg
+AD4- +AD4- ...
+AD4- +AD4- +ADw-6+AD4-client: ffff88082b6c9c00, xprt: ffff880824aef800, sn=
d+AF8-task: ffff881029c63ec0
+AD4- +AD4- +ADw-6+AD4-client: ffff88082b6c9e00, xprt: ffff880824aef800, sn=
d+AF8-task: ffff881029c63ec0
+AD4- +AD4- +ADw-6+AD4--pid- flgs status -client- --rqstp- -timeout ---ops-=
-
+AD4- +AD4- +ADw-6+AD4-18091 0080    -11 ffff88082b6c9e00   (null)      fff=
f0770ns3 ACCESS a:call+AF8-reserveresult q:xprt+AF8-sending
+AD4- +AD4- +ADw-6+AD4-client: ffff88082a244600, xprt: ffff88082a343000, sn=
d+AF8-task:   (null)
+AD4- +AD4- +ADw-6+AD4-client: ffff880829181600, xprt: ffff88082a343000, sn=
d+AF8-task:   (null)
+AD4- +AD4- +ADw-6+AD4-client: ffff880828170200, xprt: ffff880824aef800, sn=
d+AF8-task: ffff881029c63ec0
+AD4-=20
+AD4- Sorry, that output was a little messed up.  Here it is again:
+AD4-=20
+AD4- +ADw-6+AD4-client: ffff88082b6c9c00, xprt: ffff880824aef800, snd+AF8-=
task: ffff881029c63ec0
+AD4- +ADw-6+AD4-client: ffff88082b6c9e00, xprt: ffff880824aef800, snd+AF8-=
task: ffff881029c63ec0
+AD4- +ADw-6+AD4--pid- flgs status -client- --rqstp- -timeout ---ops--
+AD4- +ADw-6+AD4-18091 0080    -11 ffff88082b6c9e00   (null)        0 fffff=
fffa027b7e0 nfsv3 ACCESS a:call+AF8-reserveresult q:xprt+AF8-sending
+AD4- +ADw-6+AD4-client: ffff88082a244600, xprt: ffff88082a343000, snd+AF8-=
task:   (null)
+AD4- +ADw-6+AD4-client: ffff880829181600, xprt: ffff88082a343000, snd+AF8-=
task:   (null)
+AD4- +ADw-6+AD4-client: ffff880828170200, xprt: ffff880824aef800, snd+AF8-=
task: ffff881029c63ec0

Hi Chris,

It looks as if the problem here is that the rpc+AF8-task in question is not
being woken up. I'm aware of at least one problem with priority queues
in RHEL-6.3/CentOS-6.3, and that has been fixed in the upstream kernel.

See attachment.

Cheers
  Trond

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993F1BSACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-SUNRPC-Don-t-allow-low-priority-tasks-to-pre-empt-hi.patch"
Content-Description: 0001-SUNRPC-Don-t-allow-low-priority-tasks-to-pre-empt-hi.patch
Content-Disposition: attachment;
	filename="0001-SUNRPC-Don-t-allow-low-priority-tasks-to-pre-empt-hi.patch";
	size=4014; creation-date="Tue, 08 Jan 2013 23:10:58 GMT";
	modification-date="Tue, 08 Jan 2013 23:10:58 GMT"
Content-ID: <E94E83C9922CF1408319E05C06C93DBA@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSBjMDVlZWNmNjM2MTAxZGQ0MzQ3YjJkOGZhNDU3NjI2YmYwMDg4ZTBhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IEZyaSwgMzAgTm92IDIwMTIgMjM6NTk6MjkgLTA1MDANClN1YmplY3Q6
IFtQQVRDSF0gU1VOUlBDOiBEb24ndCBhbGxvdyBsb3cgcHJpb3JpdHkgdGFza3MgdG8gcHJlLWVt
cHQgaGlnaGVyDQogcHJpb3JpdHkgb25lcw0KDQpDdXJyZW50bHksIHRoZSBwcmlvcml0eSBxdWV1
ZXMgYXR0ZW1wdCB0byBiZSAnZmFpcicgdG8gbG93ZXIgcHJpb3JpdHkNCnRhc2tzIGJ5IHNjaGVk
dWxpbmcgdGhlbSBhZnRlciBhIGNlcnRhaW4gbnVtYmVyIG9mIGhpZ2hlciBwcmlvcml0eSB0YXNr
cw0KaGF2ZSBydW4uIFRoZSBwcm9ibGVtIGlzIHRoYXQgYm90aCB0aGUgdHJhbnNwb3J0IHNlbmQg
cXVldWUgYW5kDQp0aGUgTkZTdjQuMSBzZXNzaW9uIHNsb3QgcXVldWUgaGF2ZSBzdHJvbmcgb3Jk
ZXJpbmcgcmVxdWlyZW1lbnRzLg0KDQpUaGlzIHBhdGNoIHRoZXJlZm9yZSByZW1vdmVzIHRoZSBm
YWlybmVzcyBjb2RlIGluIGZhdm91ciBvZiBzdHJvbmcNCm9yZGVyaW5nIG9mIHRhc2sgcHJpb3Jp
dGllcy4NCg0KU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbT4NCi0tLQ0KIGluY2x1ZGUvbGludXgvc3VucnBjL3NjaGVkLmggfCAgMSAtDQog
bmV0L3N1bnJwYy9zY2hlZC5jICAgICAgICAgICB8IDQ0ICsrKysrKysrKysrKysrKysrKysrKyst
LS0tLS0tLS0tLS0tLS0tLS0tLS0tDQogMiBmaWxlcyBjaGFuZ2VkLCAyMiBpbnNlcnRpb25zKCsp
LCAyMyBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvc3VucnBjL3Nj
aGVkLmggYi9pbmNsdWRlL2xpbnV4L3N1bnJwYy9zY2hlZC5oDQppbmRleCBkYzBjM2NjLi5iNjRm
OGViIDEwMDY0NA0KLS0tIGEvaW5jbHVkZS9saW51eC9zdW5ycGMvc2NoZWQuaA0KKysrIGIvaW5j
bHVkZS9saW51eC9zdW5ycGMvc2NoZWQuaA0KQEAgLTE5Miw3ICsxOTIsNiBAQCBzdHJ1Y3QgcnBj
X3dhaXRfcXVldWUgew0KIAlwaWRfdAkJCW93bmVyOwkJCS8qIHByb2Nlc3MgaWQgb2YgbGFzdCB0
YXNrIHNlcnZpY2VkICovDQogCXVuc2lnbmVkIGNoYXIJCW1heHByaW9yaXR5OwkJLyogbWF4aW11
bSBwcmlvcml0eSAoMCBpZiBxdWV1ZSBpcyBub3QgYSBwcmlvcml0eSBxdWV1ZSkgKi8NCiAJdW5z
aWduZWQgY2hhcgkJcHJpb3JpdHk7CQkvKiBjdXJyZW50IHByaW9yaXR5ICovDQotCXVuc2lnbmVk
IGNoYXIJCWNvdW50OwkJCS8qICMgdGFzayBncm91cHMgcmVtYWluaW5nIHNlcnZpY2VkIHNvIGZh
ciAqLw0KIAl1bnNpZ25lZCBjaGFyCQlucjsJCQkvKiAjIHRhc2tzIHJlbWFpbmluZyBmb3IgY29v
a2llICovDQogCXVuc2lnbmVkIHNob3J0CQlxbGVuOwkJCS8qIHRvdGFsICMgdGFza3Mgd2FpdGlu
ZyBpbiBxdWV1ZSAqLw0KIAlzdHJ1Y3QgcnBjX3RpbWVyCXRpbWVyX2xpc3Q7DQpkaWZmIC0tZ2l0
IGEvbmV0L3N1bnJwYy9zY2hlZC5jIGIvbmV0L3N1bnJwYy9zY2hlZC5jDQppbmRleCAxYWVmYzlm
Li5kMTdhNzA0IDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy9zY2hlZC5jDQorKysgYi9uZXQvc3Vu
cnBjL3NjaGVkLmMNCkBAIC05OCw2ICs5OCwyMyBAQCBfX3JwY19hZGRfdGltZXIoc3RydWN0IHJw
Y193YWl0X3F1ZXVlICpxdWV1ZSwgc3RydWN0IHJwY190YXNrICp0YXNrKQ0KIAlsaXN0X2FkZCgm
dGFzay0+dS50a193YWl0LnRpbWVyX2xpc3QsICZxdWV1ZS0+dGltZXJfbGlzdC5saXN0KTsNCiB9
DQogDQorc3RhdGljIHZvaWQgcnBjX3NldF93YWl0cXVldWVfcHJpb3JpdHkoc3RydWN0IHJwY193
YWl0X3F1ZXVlICpxdWV1ZSwgaW50IHByaW9yaXR5KQ0KK3sNCisJcXVldWUtPnByaW9yaXR5ID0g
cHJpb3JpdHk7DQorfQ0KKw0KK3N0YXRpYyB2b2lkIHJwY19zZXRfd2FpdHF1ZXVlX293bmVyKHN0
cnVjdCBycGNfd2FpdF9xdWV1ZSAqcXVldWUsIHBpZF90IHBpZCkNCit7DQorCXF1ZXVlLT5vd25l
ciA9IHBpZDsNCisJcXVldWUtPm5yID0gUlBDX0JBVENIX0NPVU5UOw0KK30NCisNCitzdGF0aWMg
dm9pZCBycGNfcmVzZXRfd2FpdHF1ZXVlX3ByaW9yaXR5KHN0cnVjdCBycGNfd2FpdF9xdWV1ZSAq
cXVldWUpDQorew0KKwlycGNfc2V0X3dhaXRxdWV1ZV9wcmlvcml0eShxdWV1ZSwgcXVldWUtPm1h
eHByaW9yaXR5KTsNCisJcnBjX3NldF93YWl0cXVldWVfb3duZXIocXVldWUsIDApOw0KK30NCisN
CiAvKg0KICAqIEFkZCBuZXcgcmVxdWVzdCB0byBhIHByaW9yaXR5IHF1ZXVlLg0KICAqLw0KQEAg
LTEwOSw5ICsxMjYsMTEgQEAgc3RhdGljIHZvaWQgX19ycGNfYWRkX3dhaXRfcXVldWVfcHJpb3Jp
dHkoc3RydWN0IHJwY193YWl0X3F1ZXVlICpxdWV1ZSwNCiAJc3RydWN0IHJwY190YXNrICp0Ow0K
IA0KIAlJTklUX0xJU1RfSEVBRCgmdGFzay0+dS50a193YWl0LmxpbmtzKTsNCi0JcSA9ICZxdWV1
ZS0+dGFza3NbcXVldWVfcHJpb3JpdHldOw0KIAlpZiAodW5saWtlbHkocXVldWVfcHJpb3JpdHkg
PiBxdWV1ZS0+bWF4cHJpb3JpdHkpKQ0KLQkJcSA9ICZxdWV1ZS0+dGFza3NbcXVldWUtPm1heHBy
aW9yaXR5XTsNCisJCXF1ZXVlX3ByaW9yaXR5ID0gcXVldWUtPm1heHByaW9yaXR5Ow0KKwlpZiAo
cXVldWVfcHJpb3JpdHkgPiBxdWV1ZS0+cHJpb3JpdHkpDQorCQlycGNfc2V0X3dhaXRxdWV1ZV9w
cmlvcml0eShxdWV1ZSwgcXVldWVfcHJpb3JpdHkpOw0KKwlxID0gJnF1ZXVlLT50YXNrc1txdWV1
ZV9wcmlvcml0eV07DQogCWxpc3RfZm9yX2VhY2hfZW50cnkodCwgcSwgdS50a193YWl0Lmxpc3Qp
IHsNCiAJCWlmICh0LT50a19vd25lciA9PSB0YXNrLT50a19vd25lcikgew0KIAkJCWxpc3RfYWRk
X3RhaWwoJnRhc2stPnUudGtfd2FpdC5saXN0LCAmdC0+dS50a193YWl0LmxpbmtzKTsNCkBAIC0x
ODAsMjQgKzE5OSw2IEBAIHN0YXRpYyB2b2lkIF9fcnBjX3JlbW92ZV93YWl0X3F1ZXVlKHN0cnVj
dCBycGNfd2FpdF9xdWV1ZSAqcXVldWUsIHN0cnVjdCBycGNfdGFzDQogCQkJdGFzay0+dGtfcGlk
LCBxdWV1ZSwgcnBjX3FuYW1lKHF1ZXVlKSk7DQogfQ0KIA0KLXN0YXRpYyBpbmxpbmUgdm9pZCBy
cGNfc2V0X3dhaXRxdWV1ZV9wcmlvcml0eShzdHJ1Y3QgcnBjX3dhaXRfcXVldWUgKnF1ZXVlLCBp
bnQgcHJpb3JpdHkpDQotew0KLQlxdWV1ZS0+cHJpb3JpdHkgPSBwcmlvcml0eTsNCi0JcXVldWUt
PmNvdW50ID0gMSA8PCAocHJpb3JpdHkgKiAyKTsNCi19DQotDQotc3RhdGljIGlubGluZSB2b2lk
IHJwY19zZXRfd2FpdHF1ZXVlX293bmVyKHN0cnVjdCBycGNfd2FpdF9xdWV1ZSAqcXVldWUsIHBp
ZF90IHBpZCkNCi17DQotCXF1ZXVlLT5vd25lciA9IHBpZDsNCi0JcXVldWUtPm5yID0gUlBDX0JB
VENIX0NPVU5UOw0KLX0NCi0NCi1zdGF0aWMgaW5saW5lIHZvaWQgcnBjX3Jlc2V0X3dhaXRxdWV1
ZV9wcmlvcml0eShzdHJ1Y3QgcnBjX3dhaXRfcXVldWUgKnF1ZXVlKQ0KLXsNCi0JcnBjX3NldF93
YWl0cXVldWVfcHJpb3JpdHkocXVldWUsIHF1ZXVlLT5tYXhwcmlvcml0eSk7DQotCXJwY19zZXRf
d2FpdHF1ZXVlX293bmVyKHF1ZXVlLCAwKTsNCi19DQotDQogc3RhdGljIHZvaWQgX19ycGNfaW5p
dF9wcmlvcml0eV93YWl0X3F1ZXVlKHN0cnVjdCBycGNfd2FpdF9xdWV1ZSAqcXVldWUsIGNvbnN0
IGNoYXIgKnFuYW1lLCB1bnNpZ25lZCBjaGFyIG5yX3F1ZXVlcykNCiB7DQogCWludCBpOw0KQEAg
LTQ2NCw4ICs0NjUsNyBAQCBzdGF0aWMgc3RydWN0IHJwY190YXNrICpfX3JwY19maW5kX25leHRf
cXVldWVkX3ByaW9yaXR5KHN0cnVjdCBycGNfd2FpdF9xdWV1ZSAqcQ0KIAkJLyoNCiAJCSAqIENo
ZWNrIGlmIHdlIG5lZWQgdG8gc3dpdGNoIHF1ZXVlcy4NCiAJCSAqLw0KLQkJaWYgKC0tcXVldWUt
PmNvdW50KQ0KLQkJCWdvdG8gbmV3X293bmVyOw0KKwkJZ290byBuZXdfb3duZXI7DQogCX0NCiAN
CiAJLyoNCi0tIA0KMS43LjExLjcNCg0K

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA911993F1BSACEXCMBX04PRDh_--
