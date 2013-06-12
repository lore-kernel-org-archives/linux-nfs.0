Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:52752 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3FLMZD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jun 2013 08:25:03 -0400
From: Nix <nix@esperi.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS/lazy-umount/path-lookup-related panics at shutdown (at kill of processes on lazy-umounted filesystems) with 3.9.2 and 3.9.5
References: <871u89vp46.fsf@spindle.srvr.nix>
	<20130612012304.GF4165@ZenIV.linux.org.uk>
Date: Wed, 12 Jun 2013 13:08:26 +0100
In-Reply-To: <20130612012304.GF4165@ZenIV.linux.org.uk> (Al Viro's message of
	"Wed, 12 Jun 2013 02:23:04 +0100")
Message-ID: <87k3lzpm4l.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12 Jun 2013, Al Viro told this:

> On Mon, Jun 10, 2013 at 06:42:49PM +0100, Nix wrote:
>> Yes, my shutdown scripts are panicking the kernel again! They're not
>> causing filesystem corruption this time, but it's still fs-related.
>> 
>> Here's the 3.9.5 panic, seen on an x86-32 NFS client using NFSv3: NFSv4
>> was compiled in but not used. This happened when processes whose
>> current directory was on one of those NFS-mounted filesystems were being
>> killed, after it had been lazy-umounted (so by this point its cwd was in
>> a disconnected mount point).
>> 
>> [  251.246800] BUG: unable to handle kernel NULL pointer dereference at 00000004
>> [  251.256556] IP: [<c01739f6>] path_init+0xc7/0x27f
>> [  251.256556] *pde = 00000000
>> [  251.256556] Oops: 0000 [#1]
>> [  251.256556] Pid: 748, comm: su Not tainted 3.9.5+ #1
>> [  251.256556] EIP: 0060:[<c01739f6>] EFLAGS: 00010246 CPU: 0
>> [  251.256556] EIP is at path_init+0xc7/0x27f
>
> Apparently that's set_root_rcu() with current->fs being NULL.  Which comes from
> AF_UNIX connect done by some twisted call chain in context of hell knows what.

It's all NFS's fault!

>> [  251.256556]  [<c02ef8da>] ? unix_stream_connect+0xe1/0x2f7
>> [  251.256556]  [<c026a14d>] ? kernel_connect+0x10/0x14
>> [  251.256556]  [<c031ecb1>] ? xs_local_connect+0x108/0x181
>> [  251.256556]  [<c031c83b>] ? xprt_connect+0xcd/0xd1

At this point, we have a sibcall to call_connect() I think. The RPC task
of discourse happens to be local, and as the relevant comment says

		 * We want the AF_LOCAL connect to be resolved in the
		 * filesystem namespace of the process making the rpc
		 * call.  Thus we connect synchronously.

Probably this should be doing this only if said namespace isn't
disconnected and going away...

>> [  251.256556]  [<c031fd1b>] ? __rpc_execute+0x5b/0x156
>> [  251.256556]  [<c0128ac2>] ? wake_up_bit+0xb/0x19
>> [  251.256556]  [<c031b83d>] ? rpc_run_task+0x55/0x5a
>> [  251.256556]  [<c031b8bc>] ? rpc_call_sync+0x7a/0x8d
>> [  251.256556]  [<c0325127>] ? rpcb_register_call+0x11/0x20
>> [  251.256556]  [<c032548a>] ? rpcb_v4_register+0x87/0xf6

This is happening because of this code in net/sunrpc/svc.c (and, indeed,
I am running rpcbind, like everyone should be these days):

/*
 * If user space is running rpcbind, it should take the v4 UNSET
 * and clear everything for this [program, version].  If user space
 * is running portmap, it will reject the v4 UNSET, but won't have
 * any "inet6" entries anyway.  So a PMAP_UNSET should be sufficient
 * in this case to clear all existing entries for [program, version].
 */
static void __svc_unregister(struct net *net, const u32 program, const u32 version,
			     const char *progname)
{
	int error;

	error = rpcb_v4_register(net, program, version, NULL, "");

	/*
	 * User space didn't support rpcbind v4, so retry this
	 * request with the legacy rpcbind v2 protocol.
	 */
	if (error == -EPROTONOSUPPORT)
		error = rpcb_register(net, program, version, 0, 0);


Ah yes, because what unregister should do is *register* something.
That's clear as mud :)

> Why is it done in essentially random process context, anyway?  There's such thing
> as chroot, after all, which would screw that sucker as hard as NULL ->fs, but in
> a less visible way...

I don't think it is a random process context. It's all intentionally
done in the context of the process which is the last to close that
filesystem, as part of the process of tearing it down -- but it looks
like the NFS svcrpc connection code isn't expecting to be called in that
situation.
