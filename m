Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7566 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755336Ab1CAXow convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 18:44:52 -0500
Subject: Re: RPC slots count exported to userland
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110301223658.GA9759@hostway.ca>
References: <20110301223658.GA9759@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Mar 2011 18:44:35 -0500
Message-ID: <1299023075.2869.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-01 at 14:36 -0800, Simon Kirby wrote: 
> Is there a place where a summary of the same table which gets dumped out
> by "echo 0 > /proc/sys/sunrpc/debug" is exported normally to userland?
> 
> "nfsstat" accesses /proc/net/rpc/nfs and /proc/net/rpc/nfsd but they just
> seem to be running counts. It would be nice to set up a way to monitor
> when the system is close to running out of RPC slots so we can try to
> kick out whatever mount might be stuck or similar to avoid an entire
> outage.

You should be able to get that information from 
/proc/self/mountstats

See the 'mountstats' python script in recent nfs-utils sources for
details.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

