Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:42714 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752111AbdFQPJm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jun 2017 11:09:42 -0400
Date: Sat, 17 Jun 2017 08:09:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Dilger <adilger@dilger.ca>,
        Olga Kornievskaia <aglo@umich.edu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
Message-ID: <20170617150938.GA28885@infradead.org>
References: <20170614170653.58083-1-kolga@netapp.com>
 <20170615081502.GA10599@infradead.org>
 <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
 <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
 <20170616173630.GE12030@fieldses.org>
 <20170617100309.GA9469@infradead.org>
 <DE7EBCEA-5D4E-40BC-B4BA-A1DB6D5F556F@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DE7EBCEA-5D4E-40BC-B4BA-A1DB6D5F556F@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 17, 2017 at 08:42:54AM -0400, Olga Kornievskaia wrote:
> 
> > On Jun 17, 2017, at 6:03 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > On Fri, Jun 16, 2017 at 01:36:30PM -0400, J. Bruce Fields wrote:
> >> It makes a difference in the clone case, doesn't it?  (Though I'd think
> >> best there would be a special "copy to end of file" value.)
> > 
> > Clones uses a 0 length as "whole" file.  Both for the NFS operation
> > and the Linux ioctl.
> 
> Does that actually work? There is  check vfs_copy_file_range()

Please re-read the above sentence.  I'm talking about NFS clone and
IOC_CLONE_RANGE, not copy_file_range.  copy_file_range had to follow
the NFS semantics that don't have the special 0 case.
