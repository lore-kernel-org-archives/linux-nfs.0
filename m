Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756993Ab3DWSqY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:46:24 -0400
Date: Tue, 23 Apr 2013 14:46:18 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] nfs: Send atime and mtime as a 64bit value
Message-ID: <20130423184618.GG3676@fieldses.org>
References: <1366402178-1281-1-git-send-email-bjschuma@netapp.com>
 <1366402178-1281-2-git-send-email-bjschuma@netapp.com>
 <1366406549.12513.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1366406549.12513.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 19, 2013 at 09:22:29PM +0000, Myklebust, Trond wrote:
> On Fri, 2013-04-19 at 16:09 -0400, bjschuma@netapp.com wrote:
> > From: Bryan Schumaker <bjschuma@netapp.com>
> > 
> > RFC 3530 says that the seconds value of a nfstime4 structure is a 64bit
> > value, but we are instead sending a 32-bit 0 and then a 32bit conversion
> > of the 64bit Linux value.  This means that if we try to set atime to a
> > value before the epoch (touch -t 196001010101) the client will only send
> > part of the new value due to lost precision.
> > 
> > Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> 
> Thanks Bryan! Applied.
> 
> I assume that Bruce will pick up the 2/2.

Yep, thanks.

(These should go to stable too, right?)

--b.
