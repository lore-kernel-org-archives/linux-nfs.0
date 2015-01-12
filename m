Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37798 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbbALTNa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2015 14:13:30 -0500
Date: Mon, 12 Jan 2015 11:13:29 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 01/49] pnfs: Prepare for flexfiles by pulling out
 common code
Message-ID: <20150112191329.GA4985@infradead.org>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <1420590534-84063-2-git-send-email-loghyr@primarydata.com>
 <54B419AB.1060806@Netapp.com>
 <20150112191005.GD10611@jhereg.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150112191005.GD10611@jhereg.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2015 at 11:10:05AM -0800, Tom Haynes wrote:
> > Can you remind me why the common code has to go into nfsv4.ko?  Can't this all be moved into a filelayout_common module?
> 
> Yes, it could. The main dependency I wanted to avoid
> was between the flex files and the files.
> 
> I did not want to add another module...

And for the tiny amount of shared code the module seems a bit pointless.
I think for now we should make sure it's nicely separated at the source
level, that way we can easily decided to move it into another module
as needed.
