Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:45935 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab2C0VHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2012 17:07:11 -0400
Date: Tue, 27 Mar 2012 14:07:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        <linux-security-module@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
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
Subject: Re: [PATCHSET 0/6 version 2] kmod: Optional timeout on the wait in
 call_usermodehelper_exec
Message-Id: <20120327140709.60ab7bda.akpm@linux-foundation.org>
In-Reply-To: <4F711EA2.4030608@panasas.com>
References: <4F691059.30405@panasas.com>
	<4F711EA2.4030608@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 26 Mar 2012 18:57:54 -0700
Boaz Harrosh <bharrosh@panasas.com> wrote:

> My motivation is that I added yet another Kernel dependency on the
> call_usermodehelper() function and am not completely happy with the
> error case of having the user-mode program stuck forever. In such
> case I would like the Kernel part to timeout and properly error recover
> and clean up. So therefor the proposed 5th patch.

Before adding a new feature we should hear more about why you think
it's needed.  afaik we haven't needed this capability in the past ten
years or so and may not need it for another ten.  Hence we probably
shouldn't add it!

IOW, please explain at some length why you need this.  Do you think
that there are existing call sites which can usefully use this feature?
Do you expect that new callers are likely to need this?  etcetera.


Patches 1-3 are general cleanups and look good, so I grabbed those.
