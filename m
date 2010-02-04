Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45943 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932507Ab0BDAYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 19:24:30 -0500
Subject: Re: [PATCH 6/9] sunrpc: close connection when a request is
 irretrievably lost.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4B6A0F7A.3090600@oracle.com>
References: <20100203060657.12945.27293.stgit@notabene.brown>
	 <20100203063131.12945.34978.stgit@notabene.brown>
	 <4B699988.9000209@oracle.com>  <20100204082354.0bf3b7e5@notabene.brown>
	 <1265235610.5217.21.camel@localhost>  <4B69FB62.2090908@oracle.com>
	 <1265238838.2632.7.camel@localhost>  <4B6A0F7A.3090600@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Feb 2010 19:24:18 -0500
Message-ID: <1265243058.2632.23.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-02-03 at 19:06 -0500, Chuck Lever wrote: 
> My only concern would be that we perhaps should not assume that every 
> 2.6 NFS client does this.  There was an awful lot of churn at one point 
> as you were getting all of these ducks in a row.  Before you changed the 
> underlying RPC transports to return only ENOTCONN, for instance, was 
> this behavior the same?  I wouldn't swear to it in the 2.6.7 - .9 
> vintage kernels.

Every change in this area is performance sensitive, and should certainly
be tested carefully; particularly so with older kernels.

However we shouldn't forget that the changes to the client were
motivated by poor performance against a variety of servers, in a variety
of workloads and so it isn't unreasonable to expect that SUSE, Red Hat,
Debian, Oracle, etc do have an interest in fixing their NFS clients.

My question would rather therefore be: do they already have a fix in
their latest kernel revisions, and if not, are they able to give us a
timeframe?

Cheers
  Trond

