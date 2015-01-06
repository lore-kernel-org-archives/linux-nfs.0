Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:53819 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932241AbbAFShN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 13:37:13 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so31503426pab.34
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 10:37:12 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 6 Jan 2015 10:37:08 -0800
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: a simple and scalable pNFS block layout server
Message-ID: <20150106103708.70a06aba@synchrony.poochiereds.net>
In-Reply-To: <20150106175611.GA16413@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
	<20150106173222.GF12067@fieldses.org>
	<20150106175611.GA16413@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Jan 2015 18:56:11 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Tue, Jan 06, 2015 at 12:32:22PM -0500, J. Bruce Fields wrote:
> > 	- do we have evidence that this is useful in its current form?
> 
> What is your threshold for usefulness?  It passes xfstests fine, and
> shows linear scalability with multiple clients that each have 10GB
> links. 
> 
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

The wireshark decoder really only handles files layouts right now. Dros
has some patches to add flexfiles support too (once the spec is a bit
more finalized) and at that point it shouldn't be too hard to fix it to
handle block layout as well.

-- 
Jeff Layton <jlayton@primarydata.com>
