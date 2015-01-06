Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:57514 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960AbbAFR4O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 12:56:14 -0500
Date: Tue, 6 Jan 2015 18:56:11 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server
Message-ID: <20150106175611.GA16413@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <20150106173222.GF12067@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150106173222.GF12067@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 12:32:22PM -0500, J. Bruce Fields wrote:
> 	- do we have evidence that this is useful in its current form?

What is your threshold for usefulness?  It passes xfstests fine, and
shows linear scalability with multiple clients that each have 10GB
links. 

> 	- any advice on testing?  Is there was some simple virtual setup
> 	  that would allow any loser with no special hardware (e.g., me)
> 	  to check whether they've broken the block server?

Run two kvm VMs that share the same disk.  Create an XFS filesystem
on the MDS, and export it.  If the client has blkmapd running (on Debian
it needs to be started manually) it will use pNFS for accessing the
filesystem.  Verify that using the per-operation counters in
/proc/self/mounstats.  Repeat with additional clients as nessecary.

Alternatively set up a simple iSCSI target using tgt or lio and
connect to it from multiple clients.

> 	- any debugging advice?  E.g., have you checked if current
> 	  wireshark can handle the MDS traffic?

The wireshare version I've used decoded the generic pNFS operations
fine, but just dumps the layout specifics as hex data.

Enable the trace points added in this series, they track all stateid
interactions in the server.  Additіonally the pnfs debug printks on
client and server dump a lot of information.
