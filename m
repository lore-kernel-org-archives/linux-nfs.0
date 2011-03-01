Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6917 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755334Ab1CAAHu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 19:07:50 -0500
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>, Tom Haynes <Tom.Haynes@netapp.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
In-Reply-To: <1298937633.18451.9.camel@heimdal.trondhjem.org>
References: <20110228213103.GA1256@merit.edu>
	 <1298929144.8564.44.camel@heimdal.trondhjem.org>
	 <20110228215439.GD1256@merit.edu>
	 <1298930494.8564.50.camel@heimdal.trondhjem.org>
	 <20110228232258.GA1901@merit.edu>
	 <1298937633.18451.9.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Feb 2011 19:07:46 -0500
Message-ID: <1298938066.18451.12.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-28 at 19:00 -0500, Trond Myklebust wrote: 
> That's because your server is confusing the hell out of us all by giving
> out a delegation as part of the reply (in frame 5328) to the
> OPEN(CLAIM_DELEGATE_CUR) in frame 5325.
> 
> IOW: the client is in the process of returning the delegation, and asks
> to trade in the delegation stateid into an open stateid, then the server
> replies with an open stateid, and the delegation stateid...

BTW: it is interesting to note that the only place in the spec where it
is explicitly stateid that the server should not send a delegation in
the case of CLAIM_DELEGATE_CUR is in section 8.1.8 (Use of Open
Confirmation).

Perhaps we should add some words in section 14.2.16 to that effect, Tom?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

