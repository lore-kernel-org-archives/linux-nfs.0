Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:49548 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757852Ab2EILzc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 07:55:32 -0400
Message-ID: <4FAA5B24.1020306@itwm.fraunhofer.de>
Date: Wed, 09 May 2012 13:55:16 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: David Howells <dhowells@redhat.com>, Dave Chinner <david@fromorbit.com>,
        adilger@dilger.ca, bfields@fieldses.org, smfrench@gmail.com,
        ben@decadent.org.uk, Trond.Myklebust@netapp.com, roland@hack.frob.com,
        jra@samba.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
References: <20120509002420.GL5091@dastard> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <16281.1336508382@redhat.com> <20170.1336555274@redhat.com> <20120509111958.GA11345@infradead.org>
In-Reply-To: <20120509111958.GA11345@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/09/2012 01:19 PM, Christoph Hellwig wrote:
> On Wed, May 09, 2012 at 10:21:14AM +0100, David Howells wrote:
>> Dave Chinner<david@fromorbit.com>  wrote:
>>
>>> I don't think we want to expose the inode generation numbers. It is
>>> trivial to construct NFS file handles (usually just fsid, inode
>>> number and generation) with that information and hence bypass
>>> security checks to access files.
>>
>> I was asked for it by Bernd Schubert for userspace NFS servers and FUSE -
>> maybe he can say what he wants it for.
>
> It's entirely broken, as a generation number might be part of the file
> handle (and for Linux-like filesystems normally is), but it's entirely
> up to the filesystem to decide how it works.  That's why we added system
> calls to do operations on opaque file handles that the file system
> controls.  Exposing a completely meaningless "generation" is a bad idea.
>

The basic idea of generation numbers is to check if an inode was 
recycled, so only if the tuple of inode-number and generation-number 
matches we still have the same file. Kernel nfs uses that and unfs3 uses 
it via EXT2_IOC_GETVERSION, which has the overhead of an additional 
syscall. Unionfs-fuse usually keeps file open, however, it might run out 
of the maximum allowed files and I plan to add a mode to close and 
re-open files as failback mode. For that the definite knowledge if a 
file/inode is still the very same and the inode was not just recycled is 
crucial.

All of that being said, I think with open_by_handle_at() syscall we 
don't need the inode generation number any more.



Cheers,
Bernd
