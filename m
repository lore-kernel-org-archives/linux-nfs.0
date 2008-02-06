From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 6 Feb 2008 10:07:39 -0500
Message-ID: <20080206150739.GA5342@fieldses.org>
References: <20080205090132.GA8286@stro.at> <1202248931.12271.18.camel@heimdal.trondhjem.org> <003301c86888$ed735a20$0301a8c0@MURTLE> <1202310021.12647.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:37206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbYBFPIV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 10:08:21 -0500
In-Reply-To: <1202310021.12647.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 10:00:21AM -0500, Trond Myklebust wrote:
> 
> On Wed, 2008-02-06 at 19:24 +1300, Andrew Dixie wrote:
> > The following appears in the server logs:
> > Feb  4 08:28:01 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47945499/00001c88)
> > Feb  4 08:34:18 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47945499/00001c8d)
> > Feb  4 08:38:02 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47945499/00001c8f)
> > Feb  4 10:01:02 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47a627bd/00000002)
> > Feb  4 10:07:37 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47a627bd/00000005)
> > Feb  4 10:17:02 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47a627bd/0000019e)
> > Feb  5 07:59:58 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47a627bd/000003f2)
> > Feb  5 08:01:02 devfile kernel: NFSD: setclientid: string in use by 
> > client(clientid 47a627bd/000003f3)
> > 
> > These are not close to the times that it hung.
> 
> Yep. The above is entirely expected, and is not actually a bug. I keep
> asking Bruce to remove that warning...

That went into 2.6.22:

	21315edd4877b593d5bf.. "[PATCH] knfsd: nfsd4: demote "clientid
	in use" printk to a dprintk"

It may suggest a problem if this is happening a lot, though, right?

--b.

> 
> > Prior to Feb 4 it occurs 10 to 50 times a day (from when the client was 
> > running 2.6.18 kernel)
> > There is only one nfsv4 client.
> 
> OK...
> 
> Thanks
>   Trond
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
