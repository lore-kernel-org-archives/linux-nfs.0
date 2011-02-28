Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9853 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab1B1WBl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 17:01:41 -0500
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110228215439.GD1256@merit.edu>
References: <20110228213103.GA1256@merit.edu>
	 <1298929144.8564.44.camel@heimdal.trondhjem.org>
	 <20110228215439.GD1256@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Feb 2011 17:01:34 -0500
Message-ID: <1298930494.8564.50.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-28 at 16:54 -0500, Jim Rees wrote: 
> Trond Myklebust wrote:
> 
>   nfsi->delegation is released under the appropriate locks well before we
>   get here. The above line is 100% racy and risks clobbering any new
>   delegation that has been issued after the delegreturn completed...
> 
> I'd have been amazed if I'd gotten it right.  But there really is a problem
> here, the client does try to use delegations that have been returned, and
> this patch does solve that problem.  I'm happy to keep after this but would
> appreciate any suggestions or nudges in the right direction.

The procedure for returning delegations is supposed to work as follows:

     1. Remove the nfsi->delegation so that it is no longer visible to
        new open() requests 
     2. write back any dirty data to the server 
     3. Reclaim any locks 
     4. Reclaim any open stateids (using CLAIM_DELEGATE_CUR) 
     5. delegreturn

While there may indeed be the odd READ or WRITE that races between 4.
and 5., so that the server receives the delegation stateid after the
delegreturn, that shouldn't matter: the server returns an error, and the
client should retry using the new open stateid.

What is failing to work correctly here?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

