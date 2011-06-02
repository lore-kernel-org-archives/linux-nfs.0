From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCHv2 0/2] minor cleanup of sunrpc/lockd debug
Date: Thu, 02 Jun 2011 10:13:21 -0400
Message-ID: <1307024001.9634.0.camel@lade.trondhjem.org>
References: <4DE768B7.8000301@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Vasily Averin <vvs@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21616 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab1FBONY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2011 10:13:24 -0400
In-Reply-To: <4DE768B7.8000301@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-06-02 at 14:40 +0400, Vasily Averin wrote: 
> few minor cleanup of lockd/sunrpc debug messages
> 
> sunrpc: Use dprint_status() macro in call_decode()
> lockd: properly convert be32 values in debug messages
> 
> v2 changes:
> 1) inline patches
> 2) lockd: properly convert be32 values in debug messages
> 	Using be32_to_cpu() instead ntohl()

Already committed to the nfs-for-next branch of my git tree.

Thanks!
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

