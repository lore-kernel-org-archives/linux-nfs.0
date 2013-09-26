Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26961 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab3IZPXq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 11:23:46 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>
CC: "olof@lixom.net" <olof@lixom.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [RFC][PATCH 0/4] SunRPC/NFS: Use no_printk() in
Date: Thu, 26 Sep 2013 15:23:45 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9467EB040@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
 <20130926152125.GD704@fieldses.org>
In-Reply-To: <20130926152125.GD704@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Thursday, September 26, 2013 10:21 AM
> To: David Howells
> Cc: Myklebust, Trond; olof@lixom.net; linux-nfs@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [RFC][PATCH 0/4] SunRPC/NFS: Use no_printk() in
> 
> On Thu, Sep 26, 2013 at 03:45:02PM +0100, David Howells wrote:
> >
> >
> > Here's a series of patches to make SunRPC/NFS use no_printk() to
> > implement its null dfprintk() macro (ie. when RPC_DEBUG is disabled).
> > This prevents 'unused variable' errors from occurring when a variable
> > is set only for use in debugging statements and renders RPC/NFS_IFDEBUG
> unnecessary.
> 
> Does this patch series fix any actual warnings?  Or does it just change the way
> that we prevent the warnings?
> 

Right. If this is just code churn, then let's drop it. Otherwise, please explain why it is a good idea.

Cheers,
  Trond

