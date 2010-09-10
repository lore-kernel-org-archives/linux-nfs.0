Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26704 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835Ab0IJT73 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 15:59:29 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8AJxTib009609
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 12:59:29 -0700 (PDT)
Subject: Re: [PATCH 10/13] RFC: nfs: client needs to maintain list of
 inodes with active layouts
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1283450419-5648-11-git-send-email-iisaman@netapp.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-11-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 15:59:28 -0400
Message-ID: <1284148768.10062.94.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
> From: The pNFS Team <linux-nfs@vger.kernel.org>

> +static inline struct nfs_server *
> +PNFS_NFS_SERVER(struct pnfs_layout_hdr *lo)
> +{
> +	return NFS_SERVER(lo->inode);
> +}
> +

Why do we need this?
