From: <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Re: [NFS client] NFS locks not released on abnormal process termination
Date: Fri, 9 Jan 2004 04:40:55 +0100 (CET)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <33532.141.211.133.197.1073619655.squirrel@webmail.uio.no>
References: <35311.68.42.103.198.1073580656.squirrel@webmail.uio.no>
        <1073616986.525187.4709.nullmailer@yamt.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <phil@fifi.org>, <theonetruekenny@yahoo.com>,
	<linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: <yamamoto@valinux.co.jp>
In-Reply-To: <1073616986.525187.4709.nullmailer@yamt.dyndns.org>
List-ID: <nfs.lists.sourceforge.net>

>> The RPC layer blocks all signals except SIGKILL, so the signalled
>> process has no choice but to exit immediately if something gets
>> through.
>
> we're talking about interruptible mounts, aren't we?
>
> are you referring to rpc_clnt_sigmask() ?
> i think it isn't safe to assume sa_handler isn't changed during
> blocking for lock.  consider CLONE_SIGHAND, for example.

So what? If you decide handle a signal, then you are taking full
responsibility for the recovery process. It is up to _you_ to take action
to either recover the lock or to undo it, not the kernel. To determine
whether or not the lock was taken on the server you can just do a
fcntl(GETLK) call.

All the kernel cares about is that when the process exits, it needs to
clean up all the locks that are owned by that pid.

Cheers,
  Trond
