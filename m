From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 2/3] enhanced syscall ESTALE error handling (v2)
Date: Fri, 01 Feb 2008 16:51:45 -0500
Message-ID: <47A39471.4010105@redhat.com>
References: <4790C768.4080207@redhat.com> <47A387D4.70605@redhat.com> <E1JL3a0-0006H7-U3@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, trond.myklebust@fys.uio.no,
	linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JL3a0-0006H7-U3@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi wrote:
> This doesn't apply to -mm, because the ro-mounts stuff touches a lot
> of the same places as this patch.  You probably need to rebase this on
> top of those changes.
>
>   
>> This patch adds handling for the error, ESTALE, to the system
>> calls which take pathnames as arguments.  The algorithm used
>> is to detect that an ESTALE error has occurred during an
>> operation subsequent to the lookup process and then to unwind
>> appropriately and then to perform the lookup process again.
>> Eventually, either the lookup process will return an error
>> or a valid dentry/inode combination and then operation can
>> succeed or fail based on its own merits.
>>     
>
> If a broken NFS server or FUSE filesysem keeps returning ESTALE, this
> goes into an infinite loop.  How are we planning to deal with that?
>
>   

Would you describe the situation that would cause the kernel to
go into an infinite loop, please?

Please note that, at least for NFS, this looping is interruptible
by the user, so the system can't hang without anything that can
be done.

> And it has to be dealt with either in the VFS, or in the kernel parts
> of the relevant filesystems.  We can't just say, fix the broken
> servers, especially not with FUSE, where the server is totally
> untrusted.

Nope, certainly can't depend upon fixing servers.  The client
should not depend upon the server to avoid things like looping.

    Thanx...

       ps
