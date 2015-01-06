Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43925 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284AbbAFTRe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 14:17:34 -0500
Date: Tue, 6 Jan 2015 14:17:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server
Message-ID: <20150106191731.GC28003@fieldses.org>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <20150106173222.GF12067@fieldses.org>
 <20150106175611.GA16413@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150106175611.GA16413@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 06:56:11PM +0100, Christoph Hellwig wrote:
> On Tue, Jan 06, 2015 at 12:32:22PM -0500, J. Bruce Fields wrote:
> > 	- do we have evidence that this is useful in its current form?
> 
> What is your threshold for usefulness?  It passes xfstests fine, and
> shows linear scalability with multiple clients that each have 10GB
> links. 

Sounds good.  It'd be interesting to see details if they can be posted.

--b.

> > 	- any advice on testing?  Is there was some simple virtual setup
> > 	  that would allow any loser with no special hardware (e.g., me)
> > 	  to check whether they've broken the block server?
> 
> Run two kvm VMs that share the same disk.  Create an XFS filesystem
> on the MDS, and export it.  If the client has blkmapd running (on Debian
> it needs to be started manually) it will use pNFS for accessing the
> filesystem.  Verify that using the per-operation counters in
> /proc/self/mounstats.  Repeat with additional clients as nessecary.
> 
> Alternatively set up a simple iSCSI target using tgt or lio and
> connect to it from multiple clients.
> 
> > 	- any debugging advice?  E.g., have you checked if current
> > 	  wireshark can handle the MDS traffic?
> 
> The wireshare version I've used decoded the generic pNFS operations
> fine, but just dumps the layout specifics as hex data.
> 
> Enable the trace points added in this series, they track all stateid
> interactions in the server.  Additіonally the pnfs debug printks on
> client and server dump a lot of information.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
