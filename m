Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:47864 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778Ab1B1XXL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 18:23:11 -0500
Date: Mon, 28 Feb 2011 18:22:58 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
Message-ID: <20110228232258.GA1901@merit.edu>
References: <20110228213103.GA1256@merit.edu>
 <1298929144.8564.44.camel@heimdal.trondhjem.org>
 <20110228215439.GD1256@merit.edu>
 <1298930494.8564.50.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298930494.8564.50.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  The procedure for returning delegations is supposed to work as follows:
  
       1. Remove the nfsi->delegation so that it is no longer visible to
          new open() requests 
       2. write back any dirty data to the server 
       3. Reclaim any locks 
       4. Reclaim any open stateids (using CLAIM_DELEGATE_CUR) 
       5. delegreturn
  
  While there may indeed be the odd READ or WRITE that races between 4.
  and 5., so that the server receives the delegation stateid after the
  delegreturn, that shouldn't matter: the server returns an error, and the
  client should retry using the new open stateid.
  
  What is failing to work correctly here?

That helps, thanks.  I'll see if I can figure out what's going wrong.

At the server, I see a delegreturn followed by a setattr using the returned
stateid.  The server returns BAD_STATEID.  I'll look to see if the client
then retries.

At the client, I see a non-null nfsi->delegation after the delgreturn, and
the application gets a EIO.

There is a pcap here:
http://www.citi.umich.edu/projects/nfsv4/pnfs/block/bad-deleg.pcap

The stateid is 1880654d0300970000000400, the delegreturn is in packet 5589,
the client tries to use it for setattr in packet 5596.  I showed this to
Andy and Fred earlier, they may already be looking at it.

The client is running Benny's pnfs-all-latest.
