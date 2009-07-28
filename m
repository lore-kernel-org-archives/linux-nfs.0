From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: remove superfluous BUG_ON()s
Date: Tue, 28 Jul 2009 12:59:10 -0400
Message-ID: <1248800350.6205.7.camel@heimdal.trondhjem.org>
References: <200907281704.56870.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <error27@gmail.com>, corbet-T1hC0tSOHrs@public.gmane.org,
	eteo@redhat.com, Julia Lawall <julia@diku.dk>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47085 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbZG1RAt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 13:00:49 -0400
In-Reply-To: <200907281704.56870.bzolnier@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-07-28 at 17:04 +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Subject: [PATCH] nfs: remove superfluous BUG_ON()s
> 
> Remove duplicated BUG_ON()s from nfs[4]_create_server()
> (we make the same checks earlier in both functions).
> 
> This takes care of the following entries from Dan's list:
> 
> fs/nfs/client.c +1078 nfs_create_server(47) warning: variable derefenced before check 'server->nfs_client'
> fs/nfs/client.c +1079 nfs_create_server(48) warning: variable derefenced before check 'server->nfs_client->rpc_ops'
> fs/nfs/client.c +1363 nfs4_create_server(43) warning: variable derefenced before check 'server->nfs_client'
> fs/nfs/client.c +1364 nfs4_create_server(44) warning: variable derefenced before check 'server->nfs_
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Cc: corbet-T1hC0tSOHrs@public.gmane.org
> Cc: eteo@redhat.com
> Cc: Julia Lawall <julia@diku.dk>
> Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>

Thanks! I will apply...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
