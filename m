From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind
 registrations.
Date: Mon, 06 Jul 2009 12:40:50 -0400
Message-ID: <1246898450.11267.12.camel@heimdal.trondhjem.org>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	 <20090528063303.15937.62423.stgit@notabene.brown>
	 <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com>
	 <18992.35996.986951.556723@notabene.brown>
	 <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com>
	 <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com>
	 <4A51F125.5080709@suse.de>
	 <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com>
	 <4A52217E.9050207@suse.de>
	 <4E8F91E6-4E55-44BB-889B-DDB9910129BF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5271 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbZGFQlm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2009 12:41:42 -0400
In-Reply-To: <4E8F91E6-4E55-44BB-889B-DDB9910129BF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-06 at 12:31 -0400, Chuck Lever wrote:
> I have considered that.  AF_LOCAL in fact could replace all of our  
> upcall mechanisms.  However, portmapper, which doesn't support  
> AF_LOCAL, is still used in some distributions.

As could AF_NETLINK, fork(), pipes, fifos, etc... Again: why would we
want to saddle ourselves with rpc over AF_LOCAL?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
