From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 2/3] enhanced syscall ESTALE error handling (v2)
Date: Mon, 04 Feb 2008 10:55:04 -0500
Message-ID: <47A73558.2080700@redhat.com>
References: <4790C768.4080207@redhat.com> <47A387D4.70605@redhat.com> <E1JL3a0-0006H7-U3@pomaz-ex.szeredi.hu> <47A39471.4010105@redhat.com> <E1JL3yn-0006KQ-AS@pomaz-ex.szeredi.hu> <47A39D8F.9010003@redhat.com> <E1JLDIq-000747-1y@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, trond.myklebust@fys.uio.no,
	linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221AbYBDPzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2008 10:55:44 -0500
In-Reply-To: <E1JLDIq-000747-1y-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi wrote:
>>>>>       
>>>>>           
>>>> Would you describe the situation that would cause the kernel to
>>>> go into an infinite loop, please?
>>>>     
>>>>         
>>> The patch basically does:
>>>
>>> 	do {
>>> 		...
>>> 		error = inode->i_op->foo()
>>> 		...
>>> 	} while (error == ESTALE);
>>>
>>> What is the guarantee, that ->foo() will not always return ESTALE?
>>>       
>> You skimmed over some stuff, like the pathname lookup component
>> contained in the first set of dots...
>>
>> I can't guarantee that ->foo() won't always return ESTALE.
>>
>> That said, the loop is not unbreakable.  At least for NFS, a signal
>> to the process will interrupt the loop because the error returned
>> will change from ESTALE to EINTR.
>>     
>
> In FUSE interrupts are sent to userspace, and the filesystem decides
> what to do with them.  So it is entirely possible and valid for a
> filesystem to ignore an interrupt.  If an operation was non-blocking
> (such as one returning an error), then there would in fact be no
> purpose in checking interrupts.
>
>   

Why do you think that it is valid to ignore pending signals?
You seem to be asserting that it okay for processes to hang,
uninterruptibly, when accessing files on fuse mounted file
systems?

Perhaps the right error to return when there is a signal
pending is EINTR and not ESTALE or some other error?  There
has to be some way for the application to detect that its
system call was interrupted due to a signal pending.

> So while sending a signal might reliably work in NFS to break out of
> the loop, it does not necessarily work for other filesystems, and fuse
> may not be the only one affected.
>
>   

Have you noticed another one?  I would be happy to chat with the
developers for that file system to see if this support would
negatively impact them.

> Also up till now, returning ESTALE in a fuse filesystem was a
> perfectly valid thing to do.  This patch changes the behavior of that
> rather drastically.  There might be installed systems that rely on
> current behavior, and we want to avoid breaking those on a kernel
> upgrade.
>
>   

Perhaps the explanation for what ESTALE means was not clear?
If there are fuse file systems which really do support the
notion of ESTALE, then it seems to me that they would also
benefit from this support, ie. the ability to do some recovery
from the situation.

> A few solutions come to mind, perhaps the best is to introduce a
> kernel internal errno value (ERETRYSTALE), that forces the relevant
> system calls to be retried.
>
> NFS could transform ESTALE errors to ERETRYSTALE and get the desired
> behavior, while other filesystems would not be affected.

We don't need more error numbers, we've got plenty already.  :-)

Do you have anything more specific about any real problems?
I see lots of "mays" and "coulds", but I don't see anything
that I can do to make this support better.

    Thanx...

       ps
