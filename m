Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32960 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750886AbdFPRgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 13:36:31 -0400
Date: Fri, 16 Jun 2017 13:36:30 -0400
To: Andreas Dilger <adilger@dilger.ca>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
Message-ID: <20170616173630.GE12030@fieldses.org>
References: <20170614170653.58083-1-kolga@netapp.com>
 <20170615081502.GA10599@infradead.org>
 <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com>
 <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 15, 2017 at 12:35:29PM -0600, Andreas Dilger wrote:
> 
> > On Jun 15, 2017, at 7:07 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > Reason: it will not hurt any user but it will help for
> > server-to-server NFS copy because for each invocation of of
> > copy_file_range() it requires that the client sends COPY_NOTIFY, then
> > COPY and then a copy triggers a establishment of clientid/session
> > before the reading of the source file can happen. All that could be
> > saved by have a 64bit value.
> 
> What is the overhead of sending a couple of RPCs vs. copying 4GB of
> data on the server?

It makes a difference in the clone case, doesn't it?  (Though I'd think
best there would be a special "copy to end of file" value.)

--b.
