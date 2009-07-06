From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind
 registrations.
Date: Mon, 06 Jul 2009 12:22:52 -0400
Message-ID: <1246897372.11267.6.camel@heimdal.trondhjem.org>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	 <20090528063303.15937.62423.stgit@notabene.brown>
	 <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com>
	 <18992.35996.986951.556723@notabene.brown>
	 <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com>
	 <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com>
	 <4A51F125.5080709@suse.de>
	 <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com>
	 <4A52217E.9050207@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753442AbZGFQXR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2009 12:23:17 -0400
In-Reply-To: <4A52217E.9050207@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-06 at 21:38 +0530, Suresh Jayaraman wrote:
> BTW, it seems my questions on using RPC_CLNT_CREATE_ flag and using
> AF_LOCAL sockets got overshadowed (seen below) by the patch. Would
> making rpcbind using AF_LOCAL sockets a good idea or connected UDP still
> seems a better solution?

The kernel RPC client doesn't support AF_LOCAL sockets. Why would we
want to add them when we already have other mechanisms to communicate
with userland that provide the same functionality?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
