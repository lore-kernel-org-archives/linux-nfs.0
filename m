Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab1HCCHv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 22:07:51 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH v4 00/27] add block layout driver to pnfs client
Date: Tue, 2 Aug 2011 19:07:48 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778AE2@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110803014808.GA4692@merit.edu>
References: <20110729191341.GC23061@merit.edu> <1311988172.16078.15.camel@lade.trondhjem.org> <20110730032621.GB25188@merit.edu> <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com> <1312233006.23392.17.camel@lade.trondhjem.org> <1312238117.23392.19.camel@lade.trondhjem.org> <20110802022144.GA18157@merit.edu> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com> <20110802032320.GA18296@merit.edu> <1312288134.4616.21.camel@lade.trondhjem.org> <20110803014808.GA4692@merit.edu>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jim Rees" <rees@umich.edu>
Cc: "Peng Tao" <bergwolf@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "Christoph Hellwig" <hch@infradead.org>, <linux-nfs@vger.kernel.org>,
        "peter honeyman" <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Jim Rees [mailto:rees@umich.edu]
> Sent: Tuesday, August 02, 2011 9:48 PM
> To: Myklebust, Trond
> Cc: Peng Tao; Adamson, Andy; Christoph Hellwig; linux-
> nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
> 
> Here's what the test is doing.  It does multiple parallel instances of
> this,
> each one doing thousands of the following in a loop.  Console output
> with
> mutex and lock debug is in
>
http://www.citi.umich.edu/projects/nfsv4/pnfs/block/download/console.tx
> t

Hmm... That trace appears to show that the contention is between
processes trying to grab the same inode->i_mutex (in ima_file_check()
and do_unlinkat()). The question is why is the unlink process hanging
for such a long time?

I suspect another callback issue is causing the unlink() to stall:
either our client failing to handle a server callback correctly, or
possibly the server failing to respond correctly to our reply.

Can you try to turn on the callback debugging ('echo 256 >
/proc/sys/sunrpc/nfs_debug')? A wireshark trace of what is going on
during the hang itself might also help.

Cheers
  Trond
