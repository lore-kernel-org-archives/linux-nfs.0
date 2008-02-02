From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 2/3] enhanced syscall ESTALE error handling (v2)
Date: Sat, 02 Feb 2008 09:00:44 +0100
Message-ID: <E1JLDIq-000747-1y@pomaz-ex.szeredi.hu>
References: <4790C768.4080207@redhat.com> <47A387D4.70605@redhat.com> <E1JL3a0-0006H7-U3@pomaz-ex.szeredi.hu> <47A39471.4010105@redhat.com> <E1JL3yn-0006KQ-AS@pomaz-ex.szeredi.hu> <47A39D8F.9010003@redhat.com>
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org
To: staubach@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:40672 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304AbYBBIBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Feb 2008 03:01:16 -0500
In-reply-to: <47A39D8F.9010003@redhat.com> (message from Peter Staubach on
	Fri, 01 Feb 2008 17:30:39 -0500)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >>>       
> >> Would you describe the situation that would cause the kernel to
> >> go into an infinite loop, please?
> >>     
> >
> > The patch basically does:
> >
> > 	do {
> > 		...
> > 		error = inode->i_op->foo()
> > 		...
> > 	} while (error == ESTALE);
> >
> > What is the guarantee, that ->foo() will not always return ESTALE?
> 
> You skimmed over some stuff, like the pathname lookup component
> contained in the first set of dots...
> 
> I can't guarantee that ->foo() won't always return ESTALE.
> 
> That said, the loop is not unbreakable.  At least for NFS, a signal
> to the process will interrupt the loop because the error returned
> will change from ESTALE to EINTR.

In FUSE interrupts are sent to userspace, and the filesystem decides
what to do with them.  So it is entirely possible and valid for a
filesystem to ignore an interrupt.  If an operation was non-blocking
(such as one returning an error), then there would in fact be no
purpose in checking interrupts.

So while sending a signal might reliably work in NFS to break out of
the loop, it does not necessarily work for other filesystems, and fuse
may not be the only one affected.

Also up till now, returning ESTALE in a fuse filesystem was a
perfectly valid thing to do.  This patch changes the behavior of that
rather drastically.  There might be installed systems that rely on
current behavior, and we want to avoid breaking those on a kernel
upgrade.

A few solutions come to mind, perhaps the best is to introduce a
kernel internal errno value (ERETRYSTALE), that forces the relevant
system calls to be retried.

NFS could transform ESTALE errors to ERETRYSTALE and get the desired
behavior, while other filesystems would not be affected.

Miklos
