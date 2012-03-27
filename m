Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59186 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762Ab2C0B6y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 21:58:54 -0400
Message-ID: <4F711EA2.4030608@panasas.com>
Date: Mon, 26 Mar 2012 18:57:54 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        <linux-security-module@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Subject: [PATCHSET 0/6 version 2] kmod: Optional timeout on the wait in call_usermodehelper_exec
References: <4F691059.30405@panasas.com>
In-Reply-To: <4F691059.30405@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I'm re-sending the timeout optional waiting in call_usermodehelper()

Diff from version 1:
- Rebased on Olegs patches, based on Linus tree as of [e22057c]
- Fix bugs as noted by Oleg Nesterov, Thanks Oleg for looking into this.
- As noted by Oleg it would be cleaner to export from sched/core a
  new generic wait_for_complition_state() API that encapsulate all the
  different waits in one API. This is the option-A below.
  If the maintainers of kernel/sched/ do not like this API then an option-B
  is presented as a static implementation in kmod.c.
- As requested By Oleg the convert to kref is optional at the very end and
  is independent of the timeout changes.
- Added kernel/sched maintainers to the list (as advised by get_maintainers.pl)

Version 1:
My motivation is that I added yet another Kernel dependency on the
call_usermodehelper() function and am not completely happy with the
error case of having the user-mode program stuck forever. In such
case I would like the Kernel part to timeout and properly error recover
and clean up. So therefor the proposed 5th patch.

Please review and tell me what you guys think.

List of patches:
[PATCH 1/6] kmod: Unexport call_usermodehelper_freeinfo()

	This one has minor conflicts with Tetsuo's patch which ever is applied first.

[PATCH 2/6] kmod: kmod: Convert two call sites to call_usermodehelper_fns()

	Fix mem leak in the case of -ENOMEM. Tetsuo what was the optimization you
	had for this one?

[PATCH 3/6] kmod: kmod: Move call_usermodehelper_fns() to .c file and unexport all it's helpers
	Good common sense

[PATCH 4/6 OPTION-A] completion: Add new wait_for_completion_timeout_state
[PATCH 4/6 OPTION-B] kmod: {OPTION B} Add new wait_for_completion_timeout_state

	These two are interchangeable. I prefer the first one. I don't think
	kmod will be the only user for long. And it is much cleaner when wait_for_common()
	is used.
	Ingo, Peter, kernel/sched/ people please ack/nack on this approach so we can
	decide how to advance?

[PATCH 5/6] kmod: Add new call_usermodehelper_timeout() API

	And finally my motivation for all this.

[PATCH 6/6] kmod: optional: Convert the use of xchg to a kref

	This is optional. I'm including it here since I already had that code
	when I was not aware of Oleg's xchng patch. whoever is the maintainer of
	this code should decide. I'm signed on the patch but I don't have strong
	feelings one way or the other.

Thanks
Boaz

