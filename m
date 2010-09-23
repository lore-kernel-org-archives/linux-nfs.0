Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41699 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687Ab0IWVIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 17:08:18 -0400
Date: Thu, 23 Sep 2010 17:06:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
Message-ID: <20100923210642.GD14610@fieldses.org>
References: <20100921111657.330e7838@corrin.poochiereds.net>
 <20100921192005.GC4385@fieldses.org>
 <1285097787.30222.24.camel@heimdal.trondhjem.org>
 <1285099232.30222.25.camel@heimdal.trondhjem.org>
 <20100921202411.GA10570@fieldses.org>
 <1285101981.30222.27.camel@heimdal.trondhjem.org>
 <20100921145823.2ec2a81c@corrin.poochiereds.net>
 <4C9B8C72.2020405@panasas.com>
 <1285262981.14171.6.camel@heimdal.trondhjem.org>
 <DEA83846-A762-46E8-9A5B-D55215EAA8BE@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DEA83846-A762-46E8-9A5B-D55215EAA8BE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> On Sep 23, 2010, at 1:29 PM, Trond Myklebust wrote:
> > Looks fine to me, and I prefer this approach to the one we have today. 
> > 
> > Note, however, that I've already applied commit
> > d688e11007419fd060ae74d8d952a5c4ece735aa (NFSv4.1: Fix the slotid
> > initialisation in nfs_async_rename()) to the nfs-for-2.6.37 branch.
> > 
> > Are people happy with me rebasing nfs-for-2.6.37 to remove the above
> > commit, and apply this one instead?

I'm happier with incremental patches and no rebasing--I like having the
history around--but the rebase won't cause me serious practical
problems.

--b.
