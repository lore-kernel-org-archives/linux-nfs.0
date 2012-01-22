Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:51466 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752481Ab2AWAD2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2012 19:03:28 -0500
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 8569420EC7
	for <linux-nfs@vger.kernel.org>; Sun, 22 Jan 2012 19:03:27 -0500 (EST)
Date: Sun, 22 Jan 2012 14:10:21 -0700
From: Greg KH <greg@kroah.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: stable@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Patch Upstream: pnfs-obj: pNFS errors are communicated on
 iodata->pnfs_error
Message-ID: <20120122211021.GA3224@kroah.com>
References: <20120111154700.61EA4262C@git.kroah.org>
 <20120112231355.GA20151@kroah.com>
 <4F173F55.4090509@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F173F55.4090509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 18, 2012 at 11:53:25PM +0200, Boaz Harrosh wrote:
> On 01/13/2012 01:13 AM, Greg KH wrote:
> > 
> > Care to provide me such a patch for 3.0?
> > 
> > thanks,
> > 
> > greg k-h
> 
> Hi this is a 3.1 and 3.0 version of this patch. It is based on todays
> stable tree checkout. It will apply cleanly to both linux-3.0.y and
> linux-3.1.y branches.

Thanks for the backport.  As 3.1.y is now end-of-life, I've applied this
to the 3.0.y tree only.

thanks,

greg k-h
