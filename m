Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:41308 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791Ab2EINvX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 09:51:23 -0400
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <4FAA6230.7040700@itwm.fraunhofer.de>
Date: Wed, 9 May 2012 07:51:21 -0600
Cc: Christoph Hellwig <hch@infradead.org>, David Howells <dhowells@redhat.com>,
        Dave Chinner <david@fromorbit.com>, bfields@fieldses.org,
        smfrench@gmail.com, ben@decadent.org.uk, Trond.Myklebust@netapp.com,
        roland@hack.frob.com, jra@samba.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Message-Id: <F6D8E5E4-D187-4EE6-8827-6BB90BE6E8BC@dilger.ca>
References: <20120509002420.GL5091@dastard> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <16281.1336508382@redhat.com> <20170.1336555274@redhat.com> <20120509111958.GA11345@infradead.org> <4FAA5B24.1020306@itwm.fraunhofer.de> <20120509120544.GA17535@infradead.org> <4FAA6230.7040700@itwm.fraunhofer.de>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-09, at 6:25 AM, Bernd Schubert wrote:
> On 05/09/2012 02:05 PM, Christoph Hellwig wrote:
>> On Wed, May 09, 2012 at 01:55:16PM +0200, Bernd Schubert wrote:
>>> The basic idea of generation numbers is to check if an inode was
>>> recycled, so only if the tuple of inode-number and generation-number
>>> matches we still have the same file. Kernel nfs
>> 
>> NFS does not and should not look at the inode generation.  Except for a
>> bit of legacy code for the old pre-Linux 2.4 filehandles it looks at the
>> opaque file handle returned and only interpreted by the filesystem.  Any
>> userspace NFS server should do the same.
> 
> Ok, I didn't look how kernel NFS does it for quite some time already...
> User space NFS only can do it beginning with 2.6.39 - given that user space also needs to support older kernels and other OSs, which might not have open_by_handle, userspace unfortunately cannot entirely rely on that feature.

But even fewer kernels have sys_statxat() in them (i.e. none), so you can rely on that even less than open_by_handle()...

Cheers, Andreas





