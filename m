Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:20125 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab2BPUNI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 15:13:08 -0500
Subject: Re: [PATCH 08/13] SUNRPC: Add API to acquire source address
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1329422841.4279.28.camel@lade.trondhjem.org>
Date: Thu, 16 Feb 2012 15:13:04 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <5CBB0314-7446-4113-8460-56E6633E5FE5@oracle.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net> <20120215213550.3254.1420.stgit@ellison.1015granger.net> <1329422841.4279.28.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 16, 2012, at 3:07 PM, Myklebust, Trond wrote:

> On Wed, 2012-02-15 at 16:35 -0500, Chuck Lever wrote:
>> NFSv4.0 clients must send endpoint information for their callback
>> service to NFSv4.0 servers during their first contact with a server.
>> Traditionally on Linux, user space provides the callback endpoint IP
>> address via the "clientaddr=" mount option.
>> 
>> During an NFSv4 migration event, it is possible that an FSID may be
>> migrated to a destination server that is accessible via a different
>> source IP address than the source server was.  The client must update
>> callback endpoint information on the destination server so that it can
>> maintain leases and allow delegation.
>> 
>> Without a new "clientaddr=" option from user space, however, the
>> kernel itself must construct an appropriate IP address for the
>> callback update.  Provide an API in the RPC client for upper layer
>> RPC consumers to acquire a source address for a remote.
>> 
>> The mechanism used by the mount.nfs command is copied: set up a
>> connected UDP socket to the designated remote, then scrape the source
>> address off the socket.  We are careful to select the correct network
>> namespace when setting up the temporary UDP socket.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
> 
> This doesn't appear to apply (nor do several of the debugging patches).
> Was it written against the nfs-for-next branch?

No, against 3.2.  These were intended for review only, since I wasn't sure which branch to port them to.  Now I know.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




