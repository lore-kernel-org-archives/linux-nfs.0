From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2 0/67] nfs41 client patch for 2.6.30
Date: Sat, 04 Apr 2009 15:37:09 -0400
Message-ID: <1238873829.22935.4.camel@heimdal.trondhjem.org>
References: <49D4C1A9.5060900@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753680AbZDDTht (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Apr 2009 15:37:49 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-04-02 at 16:46 +0300, Benny Halevy wrote:
> Trond,
> 
> I've integrated the latest client patches from Andy
> (with a few minor changes listed below) and updated
> git://linux-nfs.org/~bhalevy/linux-pnfs.git
> branches:
> 	nfs41-for-next
> 	nfs41-for-2.6.30
> 	nfs41
> 
> nfs41-for-{next,2.6.30} contain all non-backchannel patches
> rebased onto {v2.6.29,nfs-2.6/for-next} respectively.


I've rebased it onto the latest mainline tree and put the result out on
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#nfsv41

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
