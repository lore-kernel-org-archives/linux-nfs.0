Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:44724 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932376Ab2C1S0F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 14:26:05 -0400
Message-ID: <1332959140.2528.39.camel@twins>
Subject: Re: [PATCH 4/6 OPTION-A version 3] completion: Add new
 wait_for_completion_timeout_state
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        linux-security-module@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
        Paul Turner <pjt@google.com>, Thomas Gleixner <tglx@linutronix.de>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Date: Wed, 28 Mar 2012 20:25:40 +0200
In-Reply-To: <4F735642.9030905@panasas.com>
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
	  <4F7120B6.2090509@panasas.com> <4F7126E0.5080700@panasas.com>
	 <1332835919.16159.195.camel@twins> <4F735642.9030905@panasas.com>
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-03-28 at 11:19 -0700, Boaz Harrosh wrote:
> Should I add a BUG_ON if state is not one of:
>         TASK_UNINTERRUPTIBLE
>         TASK_KILLABLE
>         TASK_INTERRUPTIBLE 

Nah, it'd be the only such site doing so, seems pointless.
