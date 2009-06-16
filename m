From: "NeilBrown" <neilb@suse.de>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
     Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Tue, 16 Jun 2009 10:21:50 +1000 (EST)
Message-ID: <99d4545537613ce76040d3655b78bdb7.squirrel@neil.brown.name>
References: <1244049027.5603.5.camel@heimdal.trondhjem.org>
    <1244138698.5203.59.camel@heimdal.trondhjem.org>
    <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com>
    <4A2902E6.2080006@RedHat.com> <4A29144A.6030405@gmail.com>
    <4A291DE3.2070105@RedHat.com>
    <1244209956.5410.33.camel@heimdal.trondhjem.org>
    <4A29243F.8080008@RedHat.com> <20090605160544.GE10975@fieldses.org>
    <1244219715.5410.40.camel@heimdal.trondhjem.org>
    <20090615230801.GA18504@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Steve Dickson" <steved@redhat.com>,
	"Tom Talpey" <tmtalpey@gmail.com>,
	"Linux NFS Mailing list" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58592 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbZFPAV6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 20:21:58 -0400
In-Reply-To: <20090615230801.GA18504@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, June 16, 2009 9:08 am, J. Bruce Fields wrote:

> +	if (host_err >= 0 && stable)
> +		wait_for_concurrent_writes(file, use_wgather, &host_err);
>

Surely you want this to be:

   if (host_err >= 0 && stable && use_wgather)
         host_err = wait_for_concurrent_writes(file);
as
 - this is more readable
 - setting last_ino and last_dev is pointless when !use_wgather
 - we aren't interested in differentiation between non-negative values of
   host_err.

NeilBrown

