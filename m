Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:45620 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab3AGTuN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2013 14:50:13 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Mon, 7 Jan 2013 19:50:10 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA91199197ESACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA91199197ESACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <55FA33A6833EEA409E9E2E4E35065F67@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-01-07 at 13:58 -0500, Chris Perl wrote:
+AD4- (Apologies up front for the long email, just trying to be thorough)
+AD4-=20
+AD4- I have come across a hang in the Linux NFS client that is reproducibl=
e.  I've
+AD4- been testing with a Fedora 17 system (3.6.10-2.fc17.x86+AF8-64), but =
I've also seen
+AD4- the same issues on CentOS 6.3 systems (2.6.32-279.5.2.el6.centos.plus=
.x86+AF8-64).
+AD4- I have not had a chance to test the latest 3.8 rc kernels yet, but qu=
ickly
+AD4- browsing their code, I didn't see major changes in the key areas to m=
ake me
+AD4- think it would make a difference (but I could certainly be wrong).
+AD4-=20
+AD4- Unfortunately, the problem is not easily reproducible.  So far, the o=
nly way
+AD4- that I've been able to trigger it is with the attached OCaml program =
+AFs-1+AF0-.
+AD4-=20
+AD4- Even more unfortunate, for you to compile and use that program, you'l=
l need to
+AD4- have a functioning OCaml environment with Jane Street's Core and Asyn=
c
+AD4- libraries available.  I can give details about the easiest way to set=
 that up
+AD4- if you want, but will hold off on that for now.  Please let me know i=
f you want
+AD4- these details.
+AD4-=20
+AD4- The idea of the program is that it spawns many threads that start sta=
t'ing and
+AD4- reading files over NFS (the paths to each file are command line args)=
 and then
+AD4- abruptly exits.
+AD4-=20
+AD4- Originally, I came across a system that hung and forced a crash dump =
of the
+AD4- kernel that I then inspected with crash +AFs-2+AF0-.  With crash I co=
uld see that the
+AD4- rpc+AF8-task referenced by the snd+AF8-task member in the relevant rp=
c+AF8-xprt didn't
+AD4- exist.
+AD4-=20
+AD4- Then after talking with some coworkers (and inspecting several more h=
ung
+AD4- systems), eventually came up with a way to reproduce the problem.  To=
 reproduce
+AD4- the problem, you actually need to take the compiled OCaml program (wh=
ich
+AD4- purposely exits very quickly after starting) and wrap it in a loop th=
at will
+AD4- immediately restart it when it exits:
+AD4-=20
+AD4- +ACQ- while :+ADs- do ./hang.opt /mnt/nfs/file+AHs-01..10+AH0- +AD4-/=
dev/null 2+AD4AJg-1+ADs- done                 =20
+AD4-=20
+AD4- In this case, file01 through 10 are 10k text files filled entirely wi=
th the
+AD4- character +ACI-A+ACI-.  /mnt/nfs is the mount point with the followin=
g options
+AD4-=20
+AD4- +ACQ- nfsstat -m
+AD4- /mnt/nfs from 127.0.0.1:/var/tmp
+AD4- Flags: rw,relatime,vers+AD0-3rsize+AD0-524288,wsize+AD0-524288,namele=
n+AD0-255,acregmin+AD0-0,acregmax+AD0-0,acdirmin+AD0-0,acdirmax+AD0-0,hard,=
proto+AD0-tcp,timeo+AD0-600,retrans+AD0-2,sec+AD0-sys,mountaddr+AD0-127.0.0=
.1,mountvers+AD0-3,mountport+AD0-20048,mountproto+AD0-tcp,local+AF8-lock+AD=
0-none,addr+AD0-127.0.0.1
+AD4-=20
+AD4- And the hang should happen within a few minutes (although sometimes i=
t did
+AD4- take quite a while for it to hang).
+AD4-=20
+AD4- I believe the problem is a race condition where one thread that curre=
ntly has
+AD4- the +AGA-rpc+AF8-xprt' for a given NFS mount locked tries to give it =
to another thread
+AD4- on the +AGA-sending' wait queue for that +AGA-rpc+AF8-xprt' (via +AF8=
AXw-xprt+AF8-lock+AF8-write+AF8-next),
+AD4- but the thread that is presumably sleeping on that wait queue never m=
ade it to
+AD4- sleep because it received a SIGKILL before it could do so.
+AD4-=20
+AD4- Here is the interaction that I believe is causing the problem:
+AD4-=20
+AD4- thread 1					     thread 2
+AD4- --------					     --------
+AD4- +AF8AXw-rpc+AF8-execute
+AD4- ...
+AD4- call+AF8-reserve
+AD4- xprt+AF8-reserve
+AD4- xprt+AF8-lock+AF8-and+AF8-alloc+AF8-slot
+AD4- xprt+AF8-lock+AF8-write
+AD4- xprt+AF8-reserve+AF8-xprt (locks rpc+AF8-xprt)
+AD4- xprt+AF8-alloc+AF8-slot
+AD4- 						     +AF8AXw-rpc+AF8-execute
+AD4- 						     ...
+AD4- 						     call+AF8-reserve
+AD4- 						     xprt+AF8-reserve
+AD4- 						     xprt+AF8-lock+AF8-and+AF8-alloc+AF8-slot
+AD4- 						     xprt+AF8-lock+AF8-write
+AD4- 						     xprt+AF8-reserve+AF8-xprt
+AD4- 						     rpc+AF8-sleep+AF8-on (+ACI-sending+ACI- wait queue)
+AD4- 						     out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-bit
+AD4- xprt+AF8-release+AF8-write
+AD4- xprt+AF8-release+AF8-xprt
+AD4- xprt+AF8-clear+AF8-locked
+AD4- +AF8AXw-xprt+AF8-lock+AF8-write+AF8-next
+AD4- 						     (receives SIGKILL from a 3rd thread)
+AD4- 						     rpc+AF8-wait+AF8-bit+AF8-killable
+AD4- 						      (will return ERESTARTSYS b/c of SIGNAL)
+AD4- rpc+AF8-wake+AF8-up+AF8-first (wq:sending,
+AD4-                     f:+AF8AXw-xprt+AF8-lock+AF8-write+AF8-func)=20
+AD4- +AF8AXw-xprt+AF8-lock+AF8-write+AF8-func (w/ task from sending)
+AD4-                                                      rpc+AF8-exit
+AD4- 						     rpc+AF8-exit+AF8-task
+AD4- ...                                                  ...
+AD4-=20
+AD4- At this point the first thread has updated rpc+AF8-xprt-+AD4-snd+AF8-=
task to point to the
+AD4- second thread, and left the rpc+AF8-xprt locked, but the second threa=
d is exiting
+AD4- because of the SIGKILL.  The real issue is the second thread was adde=
d to the
+AD4- +ACI-sending+ACI- wait queue (by rpc+AF8-sleep+AF8-on), but never act=
ually made it to sleep.
+AD4-=20
+AD4- The net effect of this is that the transport remains locked by a phan=
tom
+AD4- rpc+AF8-task.  Any other requests that come in now just go to sleep o=
n the
+AD4- rpc+AF8-xprt's sending wait queue, and no progress is made.  Any moun=
t point that
+AD4- winds up using this rpc+AF8-xprt is now hung.
+AD4-=20
+AD4- To help me understand what was happening, I used the attached systemt=
ap script
+AD4- +AFs-3+AF0- to watch the system and upon each return from +AF8AXw-rpc=
+AF8-execute, check to see
+AD4- if our task is the task currently listed in the associated rpc+AF8-xp=
rt's snd+AF8-task
+AD4- member, as I believe this should never be the case.  Running that scr=
ipt
+AD4- produced output like the following when it hung:
+AD4-=20
+AD4-=20
+AD4- +AFs-cperl+AEA-cesium +AH4-/tmp/2013-01-05+AF0AJA- sudo stap -DMAXMAP=
ENTRIES+AD0-4096 -g ./catch+AF8-locked.stp --vp 00101
+AD4- Pass 3: translated to C into +ACI-/tmp/stapMZvjDF/stap+AF8-23115b4269=
a0722946b88ddf556678e4+AF8-18614+AF8-src.c+ACI- using 354096virt/32668res/6=
728shr/25096data kb, in 90usr/10sys/101real ms.
+AD4- Pass 5: starting run.
+AD4- 1357430209194595979: 30246: thread-pool thr -+AD4- +AF8AXw-rpc+AF8-ex=
ecute: task+AD0-0xffff88011f39ec00: GETATTR
+AD4- 1357430209194599327: 30246: thread-pool thr    tk+AF8-callback: 0x0, =
tk+AF8-action: call+AF8-start
+AD4- 1357430209194602139: 30246: thread-pool thr    tk+AF8-callback: 0x0, =
tk+AF8-action: call+AF8-reserve
+AD4- 1357430209195083066: 30246: thread-pool thr    status: -512
+AD4- 1357430209195085888: 30246: thread-pool thr    -+AD4- rpc+AF8-exit:
+AD4- 1357430209195088144: 30246: thread-pool thr    tk+AF8-callback: 0x0, =
tk+AF8-action: rpc+AF8-exit+AF8-task
+AD4- 1357430209195090865: 30246: thread-pool thr    tk+AF8-callback: 0x0, =
tk+AF8-action: 0x0
+AD4- 1357430209195093517: 30246: thread-pool thr +ADw-- +AF8AXw-rpc+AF8-ex=
ecute: tk+AF8-status: 0x0
+AD4- +AF4-CPass 5: run completed in 10usr/30sys/33870real ms.
+AD4-=20
+AD4- After this happened, I used crash on the live system and indeed, this=
 task was
+AD4- the one that was listed in rpc+AF8-xprt-+AD4-snd+AF8-task for the tra=
nsport.  The rest of
+AD4- the circumstances of the hang I inferred by looking at the code, so I
+AD4- could definitely be wrong.
+AD4-=20
+AD4- The systemtap script places probe points at specific lines within the
+AD4- code (to be able to look at tk+AF8-action and tk+AF8-callback), so it=
 would need
+AD4- to be tweaked if run on a different kernel than the fedora 17 kernel =
I'm
+AD4- running it against.

Hi Chris,

Excellent sleuthing+ACE- Given the thoroughness of your explanation, I'm
pretty sure that the attached patch should fix the problem.

Cheers
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA91199197ESACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch"
Content-Description: 0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch
Content-Disposition: attachment;
	filename="0001-SUNRPC-Ensure-we-release-the-socket-write-lock-if-th.patch";
	size=1670; creation-date="Mon, 07 Jan 2013 19:50:09 GMT";
	modification-date="Mon, 07 Jan 2013 19:50:09 GMT"
Content-ID: <37ECA21B914B25498B4BDC4754166681@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSBlYzhjYmI0YWZmMjFjZDBlYWMyYzZmM2ZjNDI3M2FjNzJjZGQ5MWVmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IE1vbiwgNyBKYW4gMjAxMyAxNDozMDo0NiAtMDUwMA0KU3ViamVjdDog
W1BBVENIXSBTVU5SUEM6IEVuc3VyZSB3ZSByZWxlYXNlIHRoZSBzb2NrZXQgd3JpdGUgbG9jayBp
ZiB0aGUNCiBycGNfdGFzayBleGl0cyBlYXJseQ0KDQpJZiB0aGUgcnBjX3Rhc2sgZXhpdHMgd2hp
bGUgaG9sZGluZyB0aGUgc29ja2V0IHdyaXRlIGxvY2sgYmVmb3JlIGl0IGhhcw0KYWxsb2NhdGVk
IGFuIHJwYyBzbG90LCB0aGVuIHRoZSB1c3VhbCBtZWNoYW5pc20gZm9yIHJlbGVhc2luZyB0aGUg
d3JpdGUNCmxvY2sgaW4geHBydF9yZWxlYXNlKCkgaXMgZGVmZWF0ZWQuDQoNClRoZSBwcm9ibGVt
IG9jY3VycyBpZiB0aGUgY2FsbCB0byB4cHJ0X2xvY2tfd3JpdGUoKSBpbml0aWFsbHkgZmFpbHMs
IHNvDQp0aGF0IHRoZSBycGNfdGFzayBpcyBwdXQgb24gdGhlIHhwcnQtPnNlbmRpbmcgd2FpdCBx
dWV1ZS4gSWYgdGhlIHRhc2sNCmV4aXRzIGFmdGVyIGJlaW5nIGFzc2lnbmVkIHRoZSBsb2NrIGJ5
IF9feHBydF9sb2NrX3dyaXRlX2Z1bmMsIGJ1dA0KYmVmb3JlIGl0IGhhcyByZXRyaWVkIHRoZSBj
YWxsIHRvIHhwcnRfbG9ja19hbmRfYWxsb2Nfc2xvdCgpLCB0aGVuDQppdCBjYWxscyB4cHJ0X3Jl
bGVhc2UoKSB3aGlsZSBob2xkaW5nIHRoZSB3cml0ZSBsb2NrLCBidXQgd2lsbA0KaW1tZWRpYXRl
bHkgZXhpdCBkdWUgdG8gdGhlIHRlc3QgZm9yIHRhc2stPnRrX3Jxc3RwICE9IE5VTEwuDQoNClJl
cG9ydGVkLWJ5OiBDaHJpcyBQZXJsIDxjaHJpcy5wZXJsQGdtYWlsLmNvbT4NClNpZ25lZC1vZmYt
Ynk6IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+DQpDYzogc3Rh
YmxlQHZnZXIua2VybmVsLm9yZyBbPj0gMy4xXQ0KLS0tDQogbmV0L3N1bnJwYy94cHJ0LmMgfCA2
ICsrKystLQ0KIDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0p
DQoNCmRpZmYgLS1naXQgYS9uZXQvc3VucnBjL3hwcnQuYyBiL25ldC9zdW5ycGMveHBydC5jDQpp
bmRleCBiZDQ2MmE1Li42Njc2NDU3IDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy94cHJ0LmMNCisr
KyBiL25ldC9zdW5ycGMveHBydC5jDQpAQCAtMTEzNiwxMCArMTEzNiwxMiBAQCBzdGF0aWMgdm9p
ZCB4cHJ0X3JlcXVlc3RfaW5pdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssIHN0cnVjdCBycGNfeHBy
dCAqeHBydCkNCiB2b2lkIHhwcnRfcmVsZWFzZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQogew0K
IAlzdHJ1Y3QgcnBjX3hwcnQJKnhwcnQ7DQotCXN0cnVjdCBycGNfcnFzdAkqcmVxOw0KKwlzdHJ1
Y3QgcnBjX3Jxc3QJKnJlcSA9IHRhc2stPnRrX3Jxc3RwOw0KIA0KLQlpZiAoIShyZXEgPSB0YXNr
LT50a19ycXN0cCkpDQorCWlmIChyZXEgPT0gTlVMTCkgew0KKwkJeHBydF9yZWxlYXNlX3dyaXRl
KHRhc2stPnRrX3hwcnQsIHRhc2spOw0KIAkJcmV0dXJuOw0KKwl9DQogDQogCXhwcnQgPSByZXEt
PnJxX3hwcnQ7DQogCWlmICh0YXNrLT50a19vcHMtPnJwY19jb3VudF9zdGF0cyAhPSBOVUxMKQ0K
LS0gDQoxLjcuMTEuNw0KDQo=

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA91199197ESACEXCMBX04PRDh_--
