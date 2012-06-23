Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35953 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab2FWQJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jun 2012 12:09:29 -0400
Date: Sat, 23 Jun 2012 12:09:23 -0400
From: Fields James <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>,
        Morton Andrew <akpm@linux-foundation.org>,
        Harrosh Boaz <bharrosh@panasas.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Subject: Re: [RFC PATCH] nfs: Add NFS3PROC_UMOUNT procedure.
Message-ID: <20120623160923.GB10787@fieldses.org>
References: <1340448406-10161-1-git-send-email-linkinjeon@gmail.com>
 <02B16139-AFD6-4F06-99C0-C406B1A7E1DC@netapp.com>
 <FE90D2E0-C4C9-44BC-829F-ABE94801AB4C@netapp.com>
 <20120623155710.GA10787@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120623155710.GA10787@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 23, 2012 at 11:57:10AM -0400, Fields James wrote:
> On Sat, Jun 23, 2012 at 03:52:20PM +0000, Myklebust, Trond wrote:
> > The other objection is that NFSv3 already has a way to do this via the MOUNT protocol. We already call MOUNTPROC3_UMNT/MOUNTPROC_UMNT on unmount of a filesystem.
> > 
> > The problem with this approach is that if the NFS client crashes before it can call this function, then the server never gets notified. That is a problem that your patch has too...
> 
> Yes.  Could you instead work on describing *exactly* what the original
> problem was that prompted this?

("You" here meaning Namjae Jeon, of course).

And note here we've all read the changelog, that's not what I'm asking
for.

I want to know the details of *your* specific case.  "I have X clients
that I use for Y, periodically I want to unmount the exported filesystem
to do Z, I tried doing W but it didn't work...".

--b.
