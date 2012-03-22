Return-Path: linux-nfs-owner@vger.kernel.org
Received: from www262.sakura.ne.jp ([202.181.97.72]:51276 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab2CVWRf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 18:17:35 -0400
To: bharrosh@panasas.com
Cc: oleg@redhat.com, akpm@linux-foundation.org, rjw@sisk.pl,
        keyrings@linux-nfs.org, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        sbhamare@panasas.com, dhowells@redhat.com, eparis@redhat.com,
        srivatsa.bhat@linux.vnet.ibm.com, kay.sievers@vrfy.org,
        jmorris@namei.org, ebiederm@xmission.com, gregkh@linuxfoundation.org,
        rusty@rustcorp.com.au, tj@kernel.org, rientjes@google.com
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()API
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <4F691059.30405@panasas.com>
	<4F691383.5040506@panasas.com>
	<4F6A92FC.6060702@panasas.com>
	<20120322142758.GA12370@redhat.com>
	<4F6B789C.8020201@panasas.com>
In-Reply-To: <4F6B789C.8020201@panasas.com>
Message-Id: <201203230716.GFE32712.StOJOVFHMQOFFL@I-love.SAKURA.ne.jp>
Date: Fri, 23 Mar 2012 07:16:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
> > And please explain the use-case for the new API.
> > 
> 
> The reason I need a timeout, is because: Calling from Kernel to
> user-mode gives me the creeps. I don't trust user-mode programs,

If you can't trust user-mode programs executed via call_usermodehelper(),
you should not use call_usermodehelper(). It is executed with full privileges.
What if the program executed via call_usermodehelper() was

  #! /bin/sh
  exec /bin/rm -fr /

?

> specially when in final Control by a Distribution. Bugs can happen
> and deadlocks are a possibility.

Userspace process can be killed at any time.
Deadlock in userspace is less problematic than deadlock in kernel.

> An operation that should take
> 1/2 second and could max to at most 1.5 seconds, I can say in
> confidence that after 15 seconds, a dmesg and a clean error recovery
> is better.

Userspace process can block for long time. For example, under heavy load and
memory slashing. It is hardly possible to embed appropriate timeout value into
kernel code.

> I don't want any chance of D stating IO operations.
> (My code is in the IO path, either fsync or write-back. There is not
>  always a killable target)

Then, isn't UMH_NO_WAIT better than UMH_WAIT_PROC?

> The code path I have is easily recoverable, and if not for the scary
> message in dmesg the user will not notice.

What does your code path do if it raced with timeout (i.e. kernel code begins
recovery operation (thinking that the request failed) while userspace code
completes what the userspace code was asked to do (thinking that the request
succeeded))?

I think you should use a fork()ed wrapper in userspace for implementing
timeout.

  Userspace process - Create child and wait for appropriate timeout and exit.
    Child of userspace process - Create grandchild and wait for completion of
                                 grandchild. Tell (or recreate) grandchild to
                                 undo what the grandchild was supposed to do
                                 if parent dies before grandchild dies.

      Grandchild of userspace process - Do what parent told me to do. Undo if
                                        parent told me to undo.
