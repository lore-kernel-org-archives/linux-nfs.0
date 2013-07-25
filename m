Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755942Ab3GYOLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 10:11:11 -0400
Date: Thu, 25 Jul 2013 10:11:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Larry Keegan <lk@pfw.demon.co.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130725101143.6a22cb81@corrin.poochiereds.net>
In-Reply-To: <20130725134515.67af44e2@cs3.al.itld>
References: <20130725134515.67af44e2@cs3.al.itld>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Jul 2013 13:45:15 +0000
Larry Keegan <lk@pfw.demon.co.uk> wrote:

> Dear Chaps,
> 
> I am experiencing some inexplicable NFS behaviour which I would like to
> run past you.
> 
> I have a linux NFS server running kernel 3.10.2 and some clients
> running the same. The server is actually a pair of identical
> machines serving up a small number of ext4 filesystems atop drbd. They
> don't do much apart from serve home directories and deliver mail
> into them. These have worked just fine for aeons.
> 
> The problem I am seeing is that for the past month or so, on and off,
> one NFS client starts reporting stale NFS file handles on some part of
> the directory tree exported by the NFS server. During the outage the
> other parts of the same export remain unaffected. Then, some ten
> minutes to an hour later they're back to normal. Access to the affected
> sub-directories remains possible from the server (both directly and via
> nfs) and from other clients. There do not appear to be any errors on
> the underlying ext4 filesystems.
> 
> Each NFS client seems to get the heebie-jeebies over some directory or
> other pretty much independently. The problem affects all of the
> filesystems exported by the NFS server, but clearly I notice it first
> in home directories, and in particular in my dot subdirectories for
> things like my mail client and browser. I'd say something's up the
> spout about 20% of the time.
> 
> The server and clients are using nfs4, although for a while I tried
> nfs3 without any appreciable difference. I do not have CONFIG_FSCACHE
> set.
> 
> I wonder if anyone could tell me if they have ever come across this
> before, or what debugging settings might help me diagnose the problem?
> 
> Yours,
> 
> Larry
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Were these machines running older kernels before this started
happening? What kernel did you upgrade from if so?

What might be helpful is to do some network captures when the problem
occurs. What we want to know is whether the ESTALE errors are coming
from the server, or if the client is generating them. That'll narrow
down where we need to look for problems.

-- 
Jeff Layton <jlayton@redhat.com>
