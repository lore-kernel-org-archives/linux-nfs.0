Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10598 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942Ab1KJUwX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 15:52:23 -0500
Message-ID: <1320958342.11956.22.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/2] Enable the in-kernel id mapping to be on by default.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 10 Nov 2011 15:52:22 -0500
In-Reply-To: <1320956763-17935-1-git-send-email-steved@redhat.com>
References: <1320956763-17935-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-11-10 at 15:26 -0500, Steve Dickson wrote: 
> This patch set enables the in-kernel id mapping upcall
> mechanism, which will fix deadlocks that can occur 
> between the rpc.idmapd daemon and the kernel. 

Which deadlocks are you thinking of?

> This set also correct the binary name in the kernel 
> documentation

Note that we should also at some point change the default value of the
nfs4_disable_idmapping module parameter. Setting it to 'Y' so that the
NFS client starts by trying to use numeric u/gids with 'sec=sys' should
be safe, since we automatically fall back to using string-based
owner/group names if the server rejects numeric values.

Also note that older Linux servers return NFS4ERR_BADNAME in cases where
they should be using NFS4ERR_BADOWNER: please can distribution
maintainers make sure that they have applied commit
f6af99ec1b261e21219d5eba99e3af48fc6c32d4 (nfsd4: name->id mapping should
fail with BADOWNER not BADNAME).

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

