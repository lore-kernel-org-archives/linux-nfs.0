From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 6 Feb 2008 12:23:15 -0500
Message-ID: <20080206172315.GE5342@fieldses.org>
References: <20080205090132.GA8286@stro.at> <1202248931.12271.18.camel@heimdal.trondhjem.org> <003301c86888$ed735a20$0301a8c0@MURTLE> <1202310021.12647.6.camel@heimdal.trondhjem.org> <20080206150739.GA5342@fieldses.org> <1202310924.12647.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:59476 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407AbYBFRX2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 12:23:28 -0500
In-Reply-To: <1202310924.12647.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 10:15:23AM -0500, Trond Myklebust wrote:
> 
> On Wed, 2008-02-06 at 10:07 -0500, J. Bruce Fields wrote:
> 
> > That went into 2.6.22:
> > 
> > 	21315edd4877b593d5bf.. "[PATCH] knfsd: nfsd4: demote "clientid
> > 	in use" printk to a dprintk"
> > 
> > It may suggest a problem if this is happening a lot, though, right?
> 
> The client should always be able to generate a new unique clientid if
> this happens.

And then the client may fail to reclaim its state on the next server
reboot, or mistakenly prevent some other client from reclaiming state,
since it's not recording the new clientid in stable storage.  So if it's
happening a lot then we I suppose we should figure out better ways to
generate client id's.

--b.
