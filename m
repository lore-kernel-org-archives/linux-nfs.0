From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: nfsstat: has_stats() does not function correctly
 for NFSv4 client stats
Date: Mon, 22 Nov 2010 12:16:22 -0500
Message-ID: <4CEAA566.10808@RedHat.com>
References: <1289328603.9490.18.camel@serendib>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Harshula Jayasuriya <harshula@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750856Ab0KVRQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Nov 2010 12:16:23 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oAMHGN68032371
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 12:16:23 -0500
In-Reply-To: <1289328603.9490.18.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/09/2010 01:50 PM, Harshula Jayasuriya wrote:
> Hi,
> 
> The NFSv4 client procs/ops in "struct rpc_procinfo nfs4_procedures" is
> used to generate the NFS client stats interface:
> ------------------------------------------------------------
> # cat /proc/net/rpc/nfs 
> net 0 0 0 0
> rpc 15 0 0
> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc3 22 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 1 0
> proc4 42 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0
> 0 0 0
> 0 0 0 0 0 0 0
> ------------------------------------------------------------
> Note, for proc4, the number 42. That is the number of stats that follow
> on the same line. Currently nfsstat's has_stats() relies on this number
> to be equal to CLTPROC4_SZ. Unfortunately this is not the case. I have
> changed has_stats() not to rely on these two values being equal. This
> should also allow nfsstat to work with different kernel versions that
> expose a different number of NFS client ops.
> 
> * Fix has_stats()
> * Stop print_clnt_list() printing server stats!
> * Describe the option -3 and -4 completely in the nfsstat manpage.
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Committed...

steved.
