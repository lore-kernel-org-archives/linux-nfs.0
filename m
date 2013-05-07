Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:5299 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615Ab3EGVgv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 May 2013 17:36:51 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
Date: Tue, 7 May 2013 21:36:49 +0000
Message-ID: <1367962608.3580.10.camel@leira.trondhjem.org>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net>
	 <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
	 <20130503142421.19fb3ca6@tlielax.poochiereds.net>
	 <1367606034.3556.25.camel@leira.trondhjem.org>
	 <20130503144437.3a47e476@tlielax.poochiereds.net>
	 <A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com>
	 <20130503211810.GF5715@fieldses.org>
	 <8F91C5FB-EE7F-48F8-9ED5-6B5D8503E248@oracle.com>
	 <7F5CD894-42E9-4C65-A1BC-0885C63E560B@oracle.com>
	 <20130507210200.GF32743@fieldses.org>
In-Reply-To: <20130507210200.GF32743@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-05-07 at 17:02 -0400, J. Bruce Fields wrote:
> I suppose if gssd is running then it should always hold open the parent
> (rpc_pipefs/nfs) directory.  So if that isn't open it might be safe to
> assume we can fail immediately.

If rpc.idmapd is running, then it will do the same.

One possible solution might simply be to put up a 'gssd' pipe in
rpc_pipefs/nfs and use that as a metric. The problem is that IIRC,
rpc.gssd will release all pipes and then reopen them on getting a new
directory notification...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
