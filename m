Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:52857 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab3FLPyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jun 2013 11:54:20 -0400
Date: Wed, 12 Jun 2013 16:54:19 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Nix <nix@esperi.org.uk>
Cc: linux-kernel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS/lazy-umount/path-lookup-related panics at shutdown (at kill
 of processes on lazy-umounted filesystems) with 3.9.2 and 3.9.5
Message-ID: <20130612155419.GG4165@ZenIV.linux.org.uk>
References: <871u89vp46.fsf@spindle.srvr.nix>
 <20130612012304.GF4165@ZenIV.linux.org.uk>
 <87k3lzpm4l.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87k3lzpm4l.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 12, 2013 at 01:08:26PM +0100, Nix wrote:

> At this point, we have a sibcall to call_connect() I think. The RPC task
> of discourse happens to be local, and as the relevant comment says
> 
> 		 * We want the AF_LOCAL connect to be resolved in the
> 		 * filesystem namespace of the process making the rpc
> 		 * call.  Thus we connect synchronously.
> 
> Probably this should be doing this only if said namespace isn't
> disconnected and going away...

Namespace, shnamespace...  In this case the namespace is alive and well,
it's just that the process is getting killed and it's already past the
point where it has discarded all references to root/cwd.

> > Why is it done in essentially random process context, anyway?  There's such thing
> > as chroot, after all, which would screw that sucker as hard as NULL ->fs, but in
> > a less visible way...
> 
> I don't think it is a random process context. It's all intentionally
> done in the context of the process which is the last to close that
> filesystem, as part of the process of tearing it down -- but it looks
> like the NFS svcrpc connection code isn't expecting to be called in that
> situation.

_What_?  Suppose we have something mounted on /jail/net/foo/bar; will the
effect of process chrooted into /jail doing umount /net/foo/bar be different
from that of process outside of the jail doing umount /jail/net/foo/bar?
