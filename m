Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:42564 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757201Ab2CAWJ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:09:26 -0500
Date: Thu, 1 Mar 2012 17:09:18 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/15] SUNRPC: Add API to acquire source address
Message-ID: <20120301220918.GA3778@umich.edu>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
 <20120301220114.2138.67690.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120301220114.2138.67690.stgit@degas.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

  NFSv4.0 clients must send endpoint information for their callback
  service to NFSv4.0 servers during their first contact with a server.
  Traditionally on Linux, user space provides the callback endpoint IP
  address via the "clientaddr=" mount option.
  
  During an NFSv4 migration event, it is possible that an FSID may be
  migrated to a destination server that is accessible via a different
  source IP address than the source server was.  The client must update
  callback endpoint information on the destination server so that it can
  maintain leases and allow delegation.
  
  Without a new "clientaddr=" option from user space, however, the
  kernel itself must construct an appropriate IP address for the
  callback update.  Provide an API in the RPC client for upper layer
  RPC consumers to acquire a source address for a remote.
  
  The mechanism used by the mount.nfs command is copied: set up a
  connected UDP socket to the designated remote, then scrape the source
  address off the socket.  We are careful to select the correct network
  namespace when setting up the temporary UDP socket.

That seems like a lot of work.  On OpenBSD it's a one-liner, a call into the
routing system to get the device and source address that would be used to
talk to a given destination.  Is there no equivalent in linux?
