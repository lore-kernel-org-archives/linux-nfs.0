Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932760Ab2C1U11 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 16:27:27 -0400
Date: Wed, 28 Mar 2012 22:19:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        linux-security-module@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
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
Message-ID: <20120328201904.GA4517@redhat.com>
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com> <20120327140709.60ab7bda.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120327140709.60ab7bda.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27, Andrew Morton wrote:
>
> IOW, please explain at some length why you need this.  Do you think
> that there are existing call sites which can usefully use this feature?
> Do you expect that new callers are likely to need this?  etcetera.

Cough. Can't resist... Could you also explain why
http://marc.info/?l=linux-nfs&m=133252084301205 can't work?

To clarify, I am just curious, I am not arguing. I am asking because
if UMH_WAIT_PROC(timeout) fails with -ETIMEDOUT, then perhaps it makes
sense to not "leak" the user-space process servicing the kernel request
we were waiting for.

Oleg.

