From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 2/3] enhanced syscall ESTALE error handling (v2)
Date: Mon, 04 Feb 2008 20:02:40 +0100
Message-ID: <E1JM6aW-0003aJ-Eh@pomaz-ex.szeredi.hu>
References: <4790C768.4080207@redhat.com> <47A387D4.70605@redhat.com> <E1JL3a0-0006H7-U3@pomaz-ex.szeredi.hu> <47A39471.4010105@redhat.com> <E1JL3yn-0006KQ-AS@pomaz-ex.szeredi.hu> <47A39D8F.9010003@redhat.com> <E1JLDIq-000747-1y@pomaz-ex.szeredi.hu> <47A73558.2080700@redhat.com> <E1JM5Gh-0003Pi-Dq@pomaz-ex.szeredi.hu> <47A75CCF.4090904@redhat.com>
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org
To: staubach@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:45771 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197AbYBDTDN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 14:03:13 -0500
In-reply-to: <47A75CCF.4090904@redhat.com> (message from Peter Staubach on
	Mon, 04 Feb 2008 13:43:27 -0500)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > I don't know what NFS does, but returning EINTR without actually
> > canceling an operation in the server is generally not a good idea.
> >
> >   
> 
> This is what NFS has been doing, for several decades, and no one
> has complained yet.

Is it really?  Man nfs says something quite different (emphasis mine):

   intr        If an NFS file operation has a *major timeout* and  it  is
               hard  mounted,  then  allow signals to interupt the file
               operation and cause it to return EINTR  to  the  calling
               program.  The *default* is to *not* allow file operations to
               be *interrupted*.

> >> Have you noticed another one?  I would be happy to chat with the
> >> developers for that file system to see if this support would
> >> negatively impact them.
> >>     
> >
> > Oh, I have no idea.  And I wouldn't want to do a full audit of all the
> > filesystems to find out.  But if you do, please go ahead.
> >
> >   
> 
> Well, you brought it up.  I thought that perhaps you had something
> other than FUD.

It's not FUD, it's being careful not to break an implementation when
changing an API in a backward incompatbile way.

> Please describe this real and existing fuse installation so that I can
> better understand the situation and the real requirements here.

I have already done so:

  "Also up till now, returning ESTALE in a fuse filesystem was a
   perfectly valid thing to do.  This patch changes the behavior of
   that rather drastically.  There might be installed systems that
   rely on current behavior, and we want to avoid breaking those on a
   kernel upgrade."

Miklos
