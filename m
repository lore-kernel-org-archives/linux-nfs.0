Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53172 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752481Ab2AWADc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2012 19:03:32 -0500
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 9B67920F4D
	for <linux-nfs@vger.kernel.org>; Sun, 22 Jan 2012 19:03:32 -0500 (EST)
Date: Sun, 22 Jan 2012 14:12:02 -0700
From: Greg KH <greg@kroah.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: stable@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Patch Upstream: [PATCHES 0/2] pnfs-obj: Must return layout on IO
 error
Message-ID: <20120122211202.GB3224@kroah.com>
References: <20120111154700.5A847262B@git.kroah.org>
 <20120112231449.GB20151@kroah.com>
 <4F174005.9080403@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F174005.9080403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 18, 2012 at 11:56:21PM +0200, Boaz Harrosh wrote:
> On 01/13/2012 01:14 AM, Greg KH wrote:
> > 
> > Again, care to send this to stable@vger.kernel.org?
> > 
> > thanks,
> > 
> > greg k-h
> 
> As reply to this mail I'm sending two versions of this patch:
> 
> One for the linux-3.0.y branch (annotated linux-3.0.y)

I've applied this one.

> 2nd for the linux-3.1.y branch (annotated linux-3.1.y)

As 3.1.y is end-of-life, I didn't apply this one, but thanks anyway.

greg k-h
