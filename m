Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34953 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755084Ab1CAAA7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 19:00:59 -0500
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110228232258.GA1901@merit.edu>
References: <20110228213103.GA1256@merit.edu>
	 <1298929144.8564.44.camel@heimdal.trondhjem.org>
	 <20110228215439.GD1256@merit.edu>
	 <1298930494.8564.50.camel@heimdal.trondhjem.org>
	 <20110228232258.GA1901@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Feb 2011 19:00:33 -0500
Message-ID: <1298937633.18451.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-28 at 18:22 -0500, Jim Rees wrote: 
> Trond Myklebust wrote:
> 
>   The procedure for returning delegations is supposed to work as follows:
>   
>        1. Remove the nfsi->delegation so that it is no longer visible to
>           new open() requests 
>        2. write back any dirty data to the server 
>        3. Reclaim any locks 
>        4. Reclaim any open stateids (using CLAIM_DELEGATE_CUR) 
>        5. delegreturn
>   
>   While there may indeed be the odd READ or WRITE that races between 4.
>   and 5., so that the server receives the delegation stateid after the
>   delegreturn, that shouldn't matter: the server returns an error, and the
>   client should retry using the new open stateid.
>   
>   What is failing to work correctly here?
> 
> That helps, thanks.  I'll see if I can figure out what's going wrong.
> 
> At the server, I see a delegreturn followed by a setattr using the returned
> stateid.  The server returns BAD_STATEID.  I'll look to see if the client
> then retries.
> 
> At the client, I see a non-null nfsi->delegation after the delgreturn, and
> the application gets a EIO.

That's because your server is confusing the hell out of us all by giving
out a delegation as part of the reply (in frame 5328) to the
OPEN(CLAIM_DELEGATE_CUR) in frame 5325.

IOW: the client is in the process of returning the delegation, and asks
to trade in the delegation stateid into an open stateid, then the server
replies with an open stateid, and the delegation stateid...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

