Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:60099 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdFQKDQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jun 2017 06:03:16 -0400
Date: Sat, 17 Jun 2017 03:03:09 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Dilger <adilger@dilger.ca>,
        Olga Kornievskaia <aglo@umich.edu>,
        Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
Message-ID: <20170617100309.GA9469@infradead.org>
References: <20170614170653.58083-1-kolga@netapp.com>
 <20170615081502.GA10599@infradead.org>
 <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
 <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
 <20170616173630.GE12030@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170616173630.GE12030@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 16, 2017 at 01:36:30PM -0400, J. Bruce Fields wrote:
> It makes a difference in the clone case, doesn't it?  (Though I'd think
> best there would be a special "copy to end of file" value.)

Clones uses a 0 length as "whole" file.  Both for the NFS operation
and the Linux ioctl.
