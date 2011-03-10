From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] Move some NFSv4-only code under CONFIG_NFS_V4.
Date: Wed, 09 Mar 2011 19:26:21 -0500
Message-ID: <1299716781.22067.4.camel@heimdal.trondhjem.org>
References: <4D77F806.2030809@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Rob Landley <rlandley@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521Ab1CJA0f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Mar 2011 19:26:35 -0500
In-Reply-To: <4D77F806.2030809@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-03-09 at 15:58 -0600, Rob Landley wrote: 
> From: Rob Landley <rlandley@parallels.com>
> 
> Move some NFSv4-only stuff under CONFIG_NFS_V4.
> 
> Signed-off-by: Rob Landley <rlandley@parallels.com>
> ---
> 
> Space saved from NFSv3-only config on x86_64:
> 
>  function                                     old     new   delta
>  static.T                                   46908   46905      -3
>  nfs_start_lockd                              178     175      -3
>  nfs_get_client                               930     903     -27
>  nfs4_cb_match_client                         141       -    -141
> 
>  fs/nfs/client.c           |   88 ++++++++++++++++++------------------
>  include/linux/nfs_fs_sb.h |    4 -
>  2 files changed, 47 insertions(+), 45 deletions(-)

NACK.

The longer term project is to get rid of CONFIG_NFS_Vx. Maintaining all
these different configuration options just for the sake of saving a few
bytes here and there is a non-scalable proposition...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

