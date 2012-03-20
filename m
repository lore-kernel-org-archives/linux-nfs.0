Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51839 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759454Ab2CTXT3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 19:19:29 -0400
Message-ID: <4F691059.30405@panasas.com>
Date: Tue, 20 Mar 2012 16:18:49 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>
Subject: [PATCHSET 0/4] kmod: Optional timeout on the wait in call_usermodehelper_exec
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Hi

I'm picking on you because I don't have any one else to pick on.
The 3 first patches here, are just good for today. Please see if
you would like to take them? or tell me who should take them?

The 4th patch is an RFC, which got me looking into this.

My motivation is that I added yet another Kernel dependency on the
call_usermodehelper() function and am not completely happy with the
error case of having the user-mode program stuck forever. In such
case I would like the Kernel part to timeout and properly error recover
and clean up. So therefor the proposed 4th patch.

It is still in RFC because it is only lightly tested. I have booted
with this patch and tested my use of it, with the new timeout. I have
also dprinted the new reference counting introduced, and it does not
look like we have any reference leaks.
Though I have not seen in dmesgs one of the three possible cases.

If the General Idea is acceptable and there is a chance this gets
accepted, I will conduct heavy unit testing of all the cases and
will resubmit the 4th patch.

So please review and tell me what you guys think.

[I have CCed all these that scripts/get_maintainers.pl suggested
 so sorry for the noise for some]

The list of patches:
[PATCH 1/4] kmod: Unexport call_usermodehelper_freeinfo()
[PATCH 2/4] kmod: kmod: Convert two call sites to call_usermodehelper_fns()
[PATCH 3/4] kmod: kmod: Move call_usermodehelper_fns() to .c file and unexport it's helpers
	
	These 3 are good cleanups, regardless of any new fixtures

[RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout() API

	This patch is my motivation. Please review and comment on the
	new API, as well as the implementation details.

---
 fs/exec.c                   |    2 +-
 include/linux/kmod.h        |   47 +++++++++-----------------------
 kernel/kmod.c               |   62 +++++++++++++++++++++++++++++++++++-------
 kernel/sys.c                |   11 +------
 security/keys/request_key.c |   13 ++-------
 5 files changed, 71 insertions(+), 64 deletions(-)
---

Thanks
Boaz
