Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27027 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029Ab1K1PmQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 10:42:16 -0500
Message-ID: <1322494933.6125.21.camel@lade.trondhjem.org>
Subject: Re: [PATCH] NFSV4 :All lock operations should be sent to the server
 for resolution
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 28 Nov 2011 10:42:13 -0500
In-Reply-To: <4ED32AAB.8010800@cn.fujitsu.com>
References: <4D2FF124.7020500@cn.fujitsu.com>
		 <20110114181600.GA15352@fieldses.org>
	 <1295029762.3576.9.camel@heimdal.trondhjem.org>
	 <4ED32AAB.8010800@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-28 at 14:31 +0800, Mi Jinlong wrote: 
> Hi Trond,
> 
> Trond Myklebust:
> > The ability to cache locks is one of the main reasons for holding
> > delegations in the first place. Sure, the spec allows for non-posix
> > locking, but the Linux client doesn't.
> 
>   Would you mind tell me some about why we not support non-posix locking at NFS ?

For the very obvious reason that Linux applications are coded under the
assumption that the kernel implements POSIX locking semantics. Why would
we want to implement support for NFS features that can cause perfectly
correctly coded applications to hang and crash?

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

