Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722Ab1ALTNi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 14:13:38 -0500
Subject: Re: state manager failed on NFSv4 server
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110112185843.GA14207@merit.edu>
References: <20110112185843.GA14207@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 Jan 2011 14:13:36 -0500
Message-ID: <1294859616.2971.46.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-12 at 13:58 -0500, Jim Rees wrote: 
> A kernel built from Benny's pnfs-all-latest can no longer mount the EMC
> server because nfs4_state_manager() fails.  I suspect it doesn't like
> something about the EXCHANGE_ID reply.  This worked before Benny's last
> update (late Dec?), and I can bisect if necessary, but wondered if someone
> here can take a look and see if there is something obviously wrong.
> 
> I put a dump of the call and reply here:
> http://www.citi.umich.edu/projects/nfsv4/pnfs/block/emc-ng-state-mgr
> 
> I can of course provide more info if that would help.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

That is correct. According to your wireshark dump, your server is
returning an illegal combination of the EXCHGID4_FLAG_USE_* flags.

The combination

        (EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS |
        EXCHGID4_FLAG_USE_NON_PNFS)

is not listed in the table in section 13.1 of RFC5661 as an acceptable
return value.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

