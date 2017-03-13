Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49170 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752500AbdCMQGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Mar 2017 12:06:35 -0400
Date: Mon, 13 Mar 2017 12:06:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: delegation conflicts between NFSv3 and NFSv4 accessors
Message-ID: <20170313160631.GE11746@parsley.fieldses.org>
References: <F2A98574-693E-4F72-B7D1-5FCEA851BC7C@oracle.com>
 <1489252126.3367.4.camel@redhat.com>
 <FFE72BE2-6CD5-434D-8DC0-6A5D393BEF4C@oracle.com>
 <1489266274.3367.6.camel@redhat.com>
 <20170313132749.GA11746@parsley.fieldses.org>
 <41257C5D-BFEF-4538-99A3-BBAA4EE99EE3@oracle.com>
 <20170313160145.GD11746@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170313160145.GD11746@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 13, 2017 at 12:01:45PM -0400, J. Bruce Fields wrote:
> That wait doesn't sound bad at all.
> 
> The server could track round trip times to the clients holding
> delegations and use that to estimate the right wait time, but hopefully
> that's overkill.
> 
> I think the occasional retransmitted truncate probably isn't a big deal.
> Seems like the kind of thing the reply cache would handle well.

I haven't thought about what it'd take to implement.  Just for testing
purposes, maybe stick a 50ms wait and a retry in the JUKEBOX case in
anything under fs/nfsd/nfs3proc.c that looks like it could break a
delegation.

Jeff's proposal should also be pretty easy to prototype.

--b.
