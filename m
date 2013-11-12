Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:10054 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466Ab3KLRu0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 12:50:26 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, Weston Andros Adamson <dros@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: Thread overran stack, or stack corrupted BUG on mount
Date: Tue, 12 Nov 2013 17:50:22 +0000
Message-ID: <1384278619.4779.31.camel@leira.trondhjem.org>
References: <2C73011F-0939-434C-9E4D-13A1EB1403D7@netapp.com>
	 <20131112105539.4f804fc6@tlielax.poochiereds.net>
	 <20131112112021.1a0a60ca@tlielax.poochiereds.net>
	 <20131112165731.GD15060@fieldses.org>
In-Reply-To: <20131112165731.GD15060@fieldses.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-12 at 11:57 -0500, J. Bruce Fields wrote:
+AD4- On Tue, Nov 12, 2013 at 11:20:21AM -0500, Jeff Layton wrote:
+AD4- +AD4- On Tue, 12 Nov 2013 10:55:39 -0500
+AD4- +AD4- Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4- +AD4- On Tue, 12 Nov 2013 15:31:34 +-0000
+AD4- +AD4- +AD4- Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4- How that ends up smashing the stack, I'm not sure though.
+AD4- 
+AD4- rpc+AF8-free+AF8-client(clnt)
+AD4- 	rpc+AF8-release+AF8-client(clnt-+AD4-cl+AF8-parent)
+AD4- 		rpc+AF8-free+AF8-auth(clnt)
+AD4- 			free+AF8-free+AF8-client(clnt)
+AD4- 
+AD4- So freeing a client with N ancestors can take N times the stack as
+AD4- freeing a single client.
+AD4- 
+AD4- (Are there any other cases that can create arbitrarily long cl+AF8-parent
+AD4- chains?)

Ewww.... At this point, that would be pretty much anything that calls
rpc+AF8-clone+AF8-client+AF8-set+AF8-auth() in response to a NFS4ERR+AF8-WRONG+AF8-SEC.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
