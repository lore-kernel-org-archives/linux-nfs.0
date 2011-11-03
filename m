Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:52471 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab1KCVLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 17:11:04 -0400
Date: Thu, 3 Nov 2011 17:11:00 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Lukas Razik <linux@razik.name>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111103211100.GA8393@umich.edu>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
 <1320353685.18396.119.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320353685.18396.119.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  > [ 442.666622] NFS: failed to create MNT RPC client, status=-60
  > [ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
  > [ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
  > [ 442.667032] VFS: Insert root floppy and press ENTER
  > 
  Error 60 is ETIMEDOUT on SPARC, so it seems that the problem is
  basically the same one that you see in your 2.6.32 trace (rpcbind:
  server 137.226.167.241 not responding, timed out) except that now it is
  a fatal error.
  
  Any idea why the first RPC calls might be failing here? A switch
  misconfiguration or something like that perhaps?

Wasn't there a change in the way nfs mount options are handled by the kernel
for nfsroot about the time of 2.6.39?  Something about changing from default
udp to tcp maybe?
