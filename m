From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 06 Feb 2008 10:15:23 -0500
Message-ID: <1202310924.12647.24.camel@heimdal.trondhjem.org>
References: <20080205090132.GA8286@stro.at>
	 <1202248931.12271.18.camel@heimdal.trondhjem.org>
	 <003301c86888$ed735a20$0301a8c0@MURTLE>
	 <1202310021.12647.6.camel@heimdal.trondhjem.org>
	 <20080206150739.GA5342@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54895 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374AbYBFPP0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 10:15:26 -0500
In-Reply-To: <20080206150739.GA5342@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-06 at 10:07 -0500, J. Bruce Fields wrote:

> That went into 2.6.22:
> 
> 	21315edd4877b593d5bf.. "[PATCH] knfsd: nfsd4: demote "clientid
> 	in use" printk to a dprintk"
> 
> It may suggest a problem if this is happening a lot, though, right?

The client should always be able to generate a new unique clientid if
this happens.

Trond
