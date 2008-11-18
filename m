From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: help understanding the current (and future) state of NFSv4 locking?
Date: Mon, 17 Nov 2008 19:18:32 -0500
Message-ID: <170fa0d20811171618l140a0e26ycfc58ae7f10e6e0c@mail.gmail.com>
References: <170fa0d20811141234m3faee54dh241b9a374b7201c@mail.gmail.com>
	 <20081116194822.GI21551@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_47843_9830870.1226967512833"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:36019 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbYKRASe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 19:18:34 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1301028nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2008 16:18:32 -0800 (PST)
In-Reply-To: <20081116194822.GI21551@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_Part_47843_9830870.1226967512833
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sun, Nov 16, 2008 at 2:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Nov 14, 2008 at 03:34:56PM -0500, Mike Snitzer wrote:
>> Hello,
>>
>> I'd like to understand the state of Linux's NFSv4 server regarding the
>> NFSv4 spec's _optional_ ordered blocking lock list implementation.
>> Without something like the following patch isn't there still concern
>> for NFSv4 clients being starved from ever getting a conflicting lock
>> (local POSIX or lockd waiters would race to get it first)?
>
> Yes.  I have patches that approach the problem by:
>
>        - Defining a new type of lock type, the "provisional" lock,
>          which is just like a posix lock type, *except* that it
>          doesn't merge with other locks, and hence can still be cancelled
>          safely.
>        - Modifies the process of waking up waiters for a just-released
>          lock to make it a two-step process:
>                1. Apply a "provisional" lock, if there are no
>                   conflicts, and wake whoever was waiting for it.  (If
>                   there are still conflicts, put the lock on the new
>                   list without waking anyone.)
>                2. Allow the waiter to upgrade the provisional lock to a
>                   real posix lock (or, alternatively, to cancel it).
>        - Take advantage of the above to implement fair queuing for v4,
>          by stretching out the gap between steps 1 and 2 up to a lease
>          period, thus allowing a lock that is available but that a
>          client has yet polled for to be temporarily represented by a
>          provisional lock.
>
> The thought was that we'd also solve a couple other problems along the
> way, by:
>
>        - Preventing thundering herd problems on posix locks with lots
>          of waiters.
>        - Increasing fairness of posix locking (even among local
>          lockers).
>
> But we weren't able to actually show any improvement for posix locks
> with local waiters, and it's unclear whether anyone cares much about
> posix lock fairness.
>
> So it's unclear whether it's worth doing the 2-step process above for
> all posix lockers.  So maybe the patches should be written to instead
> implement provisional locks as an optional extra for use of the v4
> server.

Thanks for the overview.  I think that given how easy it is to starve
a v4 client (see below) something needs to give.

> A real-world test case (showing starvation of v4 clients) would be
> interesting if anyone had one.

I'm not sure what your definition of "real-world test case" is (so
maybe the following is moot) but the attached program (written by a
co-worker) can be used to easily illustrate the starvation of v4
clients.  The program tests to see how long it takes to lock/unlock a
file 1000 times.  If ran locally on the nfs-server against an exported
ext3 FS I get a "step time" of 11ms.  Ran from a v3 client: ~390ms.
Ran from a v4 client: ~430ms.

ran simultaneously on the nfs-server and the v3 client; local=~30ms, v3=~440ms
ran simultaneously on two v3 clients; both v3=~580ms
ran simultaneously on the nfs-server and the two v3 clients; both
v3=~580ms, but local ranges ~1500ms to ~9300ms
ran simultaneously on two v4 clients; v4=~430ms but with frequent
interleaved outliers ranging from ~1500ms to ~75000ms
ran simultaneously on the nfs-server and the v4 client; local=~11ms, v4=STARVED
ran simultaneously on the v3 and the v4 client; v3=~390ms, v4=STARVED

FYI, "STARVED" above doesn't mean the v4 client _never_ acquires the
lock.   It eventually acquires the lock; albeit extremely rarely (e.g.
after 5min) because v4 client polling is predisposed to lose the race
with either the hyper-active v3 client or the local locker.

Mike

------=_Part_47843_9830870.1226967512833
Content-Type: text/x-csrc; name=lock_tst.c
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fnnqaz6t0
Content-Disposition: attachment; filename=lock_tst.c

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHVuaXN0ZC5o
PgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUgPHN5cy90aW1lLmg+CiNpbmNsdWRlIDxzdHJp
bmcuaD4KI2luY2x1ZGUgPGVycm5vLmg+CgojZGVmaW5lIFNURVAgMTAwMAojZGVmaW5lIENNRCBG
X1NFVExLVwoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KSB7CglzdHJ1Y3QgZmxvY2sg
bGNfcnEgPSB7Rl9XUkxDSywgU0VFS19DVVIsIDAsIDEwMCwgMH07CglpbnQgaSwgcmV0ID0gMDsK
CWNoYXIgc3RyWzEwXTsKCXVuc2lnbmVkIGxvbmcgc2xlZXBfdGltZW91dCA9IDA7CglzdHJ1Y3Qg
dGltZXZhbCB0dl9zdGFydCwgdHZfcHJldiwgdHZfY3VyOwoJaW50IGZkMSA9IG9wZW4oYXJndlsx
XSwgT19SRFdSKSwgZmQyID0gMDsKCW9mZl90IHN0YXJ0ID0gMDsKCglnZXR0aW1lb2ZkYXkoJnR2
X3N0YXJ0LCBOVUxMKTsKCXR2X2N1ciA9IHR2X3ByZXYgPSB0dl9zdGFydDsKCglmb3IgKGk9MDs7
aSsrKSB7CgkJbGNfcnEubF90eXBlID0gRl9XUkxDSzsKCQlyZXQgPSBmY250bChmZDEsIENNRCwg
JmxjX3JxKTsKCgkJbGNfcnEubF90eXBlID0gRl9VTkxDSzsKCQlyZXQgPSBmY250bChmZDEsIENN
RCwgJmxjX3JxKTsKCgkJaWYgKDAgPT0gaSVTVEVQKSB7CgkJCWdldHRpbWVvZmRheSgmdHZfY3Vy
LCBOVUxMKTsKCQkJcHJpbnRmKCJpPSVkIHRvdCB0aW1lID0gJWRtcyAoc3RlcCB0aW1lPSAlZG1z
KVxuIiwgaS9TVEVQLAoJCQkgICAgICAgMTAwMCoodHZfY3VyLnR2X3NlYyAtIHR2X3N0YXJ0LnR2
X3NlYykgKyAodHZfY3VyLnR2X3VzZWMgLSB0dl9zdGFydC50dl91c2VjKS8xMDAwLAoJCQkgICAg
ICAgMTAwMCoodHZfY3VyLnR2X3NlYyAtIHR2X3ByZXYudHZfc2VjKSArICh0dl9jdXIudHZfdXNl
YyAtIHR2X3ByZXYudHZfdXNlYykvMTAwMCk7CgkJCXR2X3ByZXYgPSB0dl9jdXI7CgkJfQoJfQoJ
cmV0dXJuIDA7Cn0KCg==
------=_Part_47843_9830870.1226967512833--
