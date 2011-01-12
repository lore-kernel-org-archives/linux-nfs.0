Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748Ab1ALTPD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 14:15:03 -0500
Subject: Re: state manager failed on NFSv4 server
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20110112185843.GA14207@merit.edu>
Date: Wed, 12 Jan 2011 14:15:01 -0500
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Message-Id: <39E61C37-0696-4D55-A9EF-B2C3D7E2592D@netapp.com>
References: <20110112185843.GA14207@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jim

The EMC server is returning exchange_id flags = 0x00070000 which is illegal - it's claming the NON_PNFS, PNFS and DS roles. 

#define EXCHGID4_FLAG_USE_NON_PNFS              0x00010000
#define EXCHGID4_FLAG_USE_PNFS_MDS              0x00020000
#define EXCHGID4_FLAG_USE_PNFS_DS               0x00040000
#define EXCHGID4_FLAG_MASK_PNFS                 0x00070000

See Section 13.1 of RFC 5661

-->Andy 

On Jan 12, 2011, at 1:58 PM, Jim Rees wrote:

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

