Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:46597 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbcGFKGL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2016 06:06:11 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 2CFDF2800A2
	for <linux-nfs@vger.kernel.org>; Wed,  6 Jul 2016 12:06:08 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 12EF61137
	for <linux-nfs@vger.kernel.org>; Wed,  6 Jul 2016 12:06:07 +0200 (MEST)
Date: Wed, 6 Jul 2016 12:06:07 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Pankaj Singh <psingh.ait@gmail.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1841001989.22448255.1467799567282.JavaMail.zimbra@desy.de>
In-Reply-To: <CAPrqf91tFmR3BVk8RbBbXvMsFa-SOC2WKqGvsb-LvTiLUT61hA@mail.gmail.com>
References: <CAPrqf91tFmR3BVk8RbBbXvMsFa-SOC2WKqGvsb-LvTiLUT61hA@mail.gmail.com>
Subject: Re: When can nfsv3 returns nfs3err_jukebox to client?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

----- Original Message -----
> From: "Pankaj Singh" <psingh.ait@gmail.com>
> To: linux-nfs@vger.kernel.org
> Sent: Wednesday, July 6, 2016 7:52:45 AM
> Subject: When can nfsv3 returns nfs3err_jukebox to client?

> Hi All,
> 
> I have read in the RFC 1813 that "nfs3err_jukebox" will be return only
> when server is not able to finish the RPC request within time. To
> indicate client to wait and retry again.
> 
> Could anyone tell me is there any senario where NFSv3 or SUN RPC can
> send this error to client, if not returned from base filesystem?
> 

If a migrating file system exported through NFS, then server may return
err_jukebox/delay to the client on an IO request while mounting the offline
volume or tape to make it accessible.

Tigran.

> Here base filesystem means exporting file system via NFS.
> 
> --
> Regards,
> Pankaj SIngh
> Phone No: 8826266889
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
