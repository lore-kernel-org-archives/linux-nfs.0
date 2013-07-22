Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f178.google.com ([209.85.214.178]:53428 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab3GVXz7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 19:55:59 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so8819646obc.37
        for <linux-nfs@vger.kernel.org>; Mon, 22 Jul 2013 16:55:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130723010250.5a3465ec@xenia.leun.net>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
	<20130723010250.5a3465ec@xenia.leun.net>
Date: Mon, 22 Jul 2013 16:55:58 -0700
Message-ID: <CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH
 v3 13/16] futex: use freezable blocking call)
From: Colin Cross <ccross@android.com>
To: Michael Leun <lkml20130126@newton.leun.net>
Cc: lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Content-Type: multipart/mixed; boundary=047d7b3a7f8004216704e2226b54
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--047d7b3a7f8004216704e2226b54
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Jul 22, 2013 at 4:02 PM, Michael Leun
<lkml20130126@newton.leun.net> wrote:
> On Mon,  6 May 2013 16:50:18 -0700
> Colin Cross <ccross@android.com> wrote:
>
>> Avoid waking up every thread sleeping in a futex_wait call during
> [...]
>
> With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
> displaying 0% of saving image to disk.
>
> echo "1" >/sys/power/state still works.
>
> Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4, reverting
> that from 3.11-rc2 makes s2disk working again.
>

I think the expanded use of the freezable_* helpers is exposing an
existing bug in hibernation.  The SNAPSHOT_FREEZE ioctl calls
freeze_processes(), which sets the global system_freezing_cnt and
pm_freezing.  try_to_freeze_tasks then sends every process except
current a signal which causes them all to end up in the refrigerator.
The current task then returns back to userspace and continues its work
to suspend to disk.  If that task ever hits a call to try_to_freeze()
in the kernel, it will see system_freezing_cnt and pm_freezing=true
and freeze, and suspend to disk will hang forever.  It could hit
try_to_freeze() because of a signal delivered to the task, or from
calling any syscall that uses a freezable_* helper like the one I
added to sys_futex.

I think the right solution is to add a flag to the freezing task that
marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
normally used on kernel threads, can you see if the attached patch
helps?

--047d7b3a7f8004216704e2226b54
Content-Type: application/octet-stream;
	name="0001-power-set-PF_NOFREEZE-flag-on-SNAPSHOT_FREEZE-task.patch"
Content-Disposition: attachment;
	filename="0001-power-set-PF_NOFREEZE-flag-on-SNAPSHOT_FREEZE-task.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hjgc1d5z0

RnJvbSAwZjIyZjJiMzU3YjA2MjA4ZmM3YzBiODJjZTNmMDkyOWQwMDg3N2NhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDb2xpbiBDcm9zcyA8Y2Nyb3NzQGFuZHJvaWQuY29tPgpEYXRl
OiBNb24sIDIyIEp1bCAyMDEzIDE2OjUzOjE1IC0wNzAwClN1YmplY3Q6IFtQQVRDSF0gcG93ZXI6
IHNldCBQRl9OT0ZSRUVaRSBmbGFnIG9uIFNOQVBTSE9UX0ZSRUVaRSB0YXNrCgpUaGUgdGFzayB0
aGF0IGNhbGxzIHRoZSBTTkFQU0hPVF9GUkVFWkUgaW9jdGwgbmVlZHMgdG8gcmV0dXJuIGJhY2sK
dG8gdXNlcnNwYWNlIGFuZCBjb250aW51ZSBwcmVwYXJpbmcgYSBzdXNwZW5kLXRvLWRpc2sgaW1h
Z2UuIFNldAp0aGUgUEZfTk9GUkVFWkUgZmxhZyBvbiBpdCBzbyB0aGF0IGl0IGRvZXNuJ3QgYWNj
aWRlbnRhbGx5IGZyZWV6ZQppZiBpdCBjb21lcyBhY3Jvc3MgYSBjYWxsIHRvIHRyeV90b19mcmVl
emUoKS4KClJlcG9ydGVkLWJ5OiBNaWNoYWVsIExldW4gPGxrbWwyMDEzMDEyNkBuZXd0b24ubGV1
bi5uZXQ+ClNpZ25lZC1vZmYtYnk6IENvbGluIENyb3NzIDxjY3Jvc3NAYW5kcm9pZC5jb20+Ci0t
LQoga2VybmVsL3Bvd2VyL3VzZXIuYyB8IDIgKysKIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlv
bnMoKykKCmRpZmYgLS1naXQgYS9rZXJuZWwvcG93ZXIvdXNlci5jIGIva2VybmVsL3Bvd2VyL3Vz
ZXIuYwppbmRleCA0ZWQ4MWU3Li4xN2Y5YzIwIDEwMDY0NAotLS0gYS9rZXJuZWwvcG93ZXIvdXNl
ci5jCisrKyBiL2tlcm5lbC9wb3dlci91c2VyLmMKQEAgLTIxOSw2ICsyMTksNyBAQCBzdGF0aWMg
bG9uZyBzbmFwc2hvdF9pb2N0bChzdHJ1Y3QgZmlsZSAqZmlscCwgdW5zaWduZWQgaW50IGNtZCwK
IAkJc3lzX3N5bmMoKTsKIAkJcHJpbnRrKCJkb25lLlxuIik7CiAKKwkJY3VycmVudC0+ZmxhZ3Mg
fD0gUEZfTk9GUkVFWkU7CiAJCWVycm9yID0gZnJlZXplX3Byb2Nlc3NlcygpOwogCQlpZiAoIWVy
cm9yKQogCQkJZGF0YS0+ZnJvemVuID0gMTsKQEAgLTIyOSw2ICsyMzAsNyBAQCBzdGF0aWMgbG9u
ZyBzbmFwc2hvdF9pb2N0bChzdHJ1Y3QgZmlsZSAqZmlscCwgdW5zaWduZWQgaW50IGNtZCwKIAkJ
CWJyZWFrOwogCQlwbV9yZXN0b3JlX2dmcF9tYXNrKCk7CiAJCXRoYXdfcHJvY2Vzc2VzKCk7CisJ
CWN1cnJlbnQtPmZsYWdzICY9IH5QRl9OT0ZSRUVaRTsKIAkJZGF0YS0+ZnJvemVuID0gMDsKIAkJ
YnJlYWs7CiAKLS0gCjEuOC4zCgo=
--047d7b3a7f8004216704e2226b54--
