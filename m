Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42855 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911Ab2D3PJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 11:09:17 -0400
Date: Mon, 30 Apr 2012 11:09:14 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: nfsv4@ietf.org, Bill Baker <Bill.Baker@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] NFSv4 UCS client implementation experience
Message-ID: <20120430150914.GA3675@fieldses.org>
References: <BF46E9F2-5675-4914-AD5F-9F43CDE9DBD4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BF46E9F2-5675-4914-AD5F-9F43CDE9DBD4@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 12:05:44PM -0400, Chuck Lever wrote:
> 2.  The current Linux NFS server implementation does not tolerate UCS clients
> 
> I tried a simple test with the Linux UCS client and current stock NFS server implementations.  I mounted each server via NFSv4.0 by its IPv4 and its IPv6 address.  The UCS client's server trunking discovery algorithm should recognize that these addresses represent the same server instance.  For a Solaris 11 FCS server, this worked as expected.
> 
> For the Linux Fedora 16 server, this test failed.  The server returned a different clientid4 for the second mount, even though the client presented the same nfs_client_id4 and boot verifier, and the first mount's lease had not expired.  In addition, the server responded with NFS4ERR_CLID_INUSE when the client attempted a SETCLIENTID_CONFIRM.  The second mount was thus prevented.  The Linux NFS community agrees the Linux server's behavior is incorrect.

Yep.

Note though that both failures are probably due to the rpc's arriving
from two different client addresses, rather than to two different server
addresses.

--b.
