From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 2/3] enhanced syscall ESTALE error handling (v2)
Date: Mon, 04 Feb 2008 18:38:07 +0100
Message-ID: <E1JM5Gh-0003Pi-Dq@pomaz-ex.szeredi.hu>
References: <4790C768.4080207@redhat.com> <47A387D4.70605@redhat.com> <E1JL3a0-0006H7-U3@pomaz-ex.szeredi.hu> <47A39471.4010105@redhat.com> <E1JL3yn-0006KQ-AS@pomaz-ex.szeredi.hu> <47A39D8F.9010003@redhat.com> <E1JLDIq-000747-1y@pomaz-ex.szeredi.hu> <47A73558.2080700@redhat.com>
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org
To: staubach@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <47A73558.2080700@redhat.com> (message from Peter Staubach on
	Mon, 04 Feb 2008 10:55:04 -0500)
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > In FUSE interrupts are sent to userspace, and the filesystem decides
> > what to do with them.  So it is entirely possible and valid for a
> > filesystem to ignore an interrupt.  If an operation was non-blocking
> > (such as one returning an error), then there would in fact be no
> > purpose in checking interrupts.
> >
> >   
> 
> Why do you think that it is valid to ignore pending signals?
> You seem to be asserting that it okay for processes to hang,
> uninterruptibly, when accessing files on fuse mounted file
> systems?
> 
> Perhaps the right error to return when there is a signal
> pending is EINTR and not ESTALE or some other error?  There
> has to be some way for the application to detect that its
> system call was interrupted due to a signal pending.

Traditionally a lot of filesystem related system calls are not
interruptible, and for good reason.  For example what happens, if an
app receives a signal, while the filesystem is performing a rename()
request?  It would be very confusing if the call returned EINTR, but
the rename would successfully complete regardless.

We had a related problem with the open(O_CREAT) call in fuse, which
was interruptible between the creation and the actual open because of
a design mistake.  So it could return EINTR, after the file was
created, and this broke a real world application (don't have details
at hand, but could dig them out if you are interested).

I don't know what NFS does, but returning EINTR without actually
canceling an operation in the server is generally not a good idea.

> > So while sending a signal might reliably work in NFS to break out of
> > the loop, it does not necessarily work for other filesystems, and fuse
> > may not be the only one affected.
> >
> >   
> 
> Have you noticed another one?  I would be happy to chat with the
> developers for that file system to see if this support would
> negatively impact them.

Oh, I have no idea.  And I wouldn't want to do a full audit of all the
filesystems to find out.  But if you do, please go ahead.

> > A few solutions come to mind, perhaps the best is to introduce a
> > kernel internal errno value (ERETRYSTALE), that forces the relevant
> > system calls to be retried.
> >
> > NFS could transform ESTALE errors to ERETRYSTALE and get the desired
> > behavior, while other filesystems would not be affected.
> 
> We don't need more error numbers, we've got plenty already.  :-)

That's a rather poor excuse against a simple solution which would
spare us some backward compatibility problems.

> Do you have anything more specific about any real problems?
> I see lots of "mays" and "coulds", but I don't see anything
> that I can do to make this support better.

Implement the above suggestion?  Or something else.

Otherwise I have to NAK this patch due to the possibility of it
breaking existing fuse installations.

Thanks,
Miklos
