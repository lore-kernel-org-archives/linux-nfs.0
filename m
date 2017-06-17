Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:13538 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751957AbdFQMnD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Jun 2017 08:43:03 -0400
Content-Type: text/plain; charset=us-ascii
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170617100309.GA9469@infradead.org>
Date: Sat, 17 Jun 2017 08:42:54 -0400
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Dilger <adilger@dilger.ca>,
        Olga Kornievskaia <aglo@umich.edu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <DE7EBCEA-5D4E-40BC-B4BA-A1DB6D5F556F@netapp.com>
References: <20170614170653.58083-1-kolga@netapp.com>
 <20170615081502.GA10599@infradead.org>
 <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
 <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
 <20170616173630.GE12030@fieldses.org> <20170617100309.GA9469@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 17, 2017, at 6:03 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Fri, Jun 16, 2017 at 01:36:30PM -0400, J. Bruce Fields wrote:
>> It makes a difference in the clone case, doesn't it?  (Though I'd think
>> best there would be a special "copy to end of file" value.)
> 
> Clones uses a 0 length as "whole" file.  Both for the NFS operation
> and the Linux ioctl.

Does that actually work? There is  check vfs_copy_file_range()

if (len == 0)
	return 0;

