From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel call trace on NFS-mount (using autofs).
Date: Tue, 20 May 2008 15:37:16 -0400
Message-ID: <1211312236.23156.21.camel@localhost>
References: <48331EAE.6060107@krogh.cc>
	 <1211311573.23156.10.camel@localhost>  <4833272B.9030602@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:52973 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756462AbYETThT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 15:37:19 -0400
In-Reply-To: <4833272B.9030602-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 21:31 +0200, Jesper Krogh wrote:
> Trond Myklebust wrote:
>   > That appears to be crashing in generic VFS code rather than in anything
> > nfs specific, so I'd suggest reposting this Oops to linux-fsdevel. It
> > would be nice if you could first try to reproduce it with 2.6.25,
> > though.
> 
> Can I safely upgrade kernel to 2.6.25 without changing userspace utils
> and autofs?

Normally that should be fine as long as you don't enable any new
features that explicitly state in the kconfig file that they need
updated utilities.

> It is not particulary repoducible. I happens "every second day on a 
> random node of a set of around 48".

If it is difficult to reproduce, then you can always try posting the
existing Oops (mentioning the above), and seeing if that elicits any
response. It may be that this proves to be a known bug...

Cheers
  Trond

