Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38525 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab2BEKJv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 05:09:51 -0500
Received: by eaah12 with SMTP id h12so2087502eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2012 02:09:50 -0800 (PST)
Message-ID: <4F2E556A.7040707@tonian.com>
Date: Sun, 05 Feb 2012 12:09:46 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: pNFS: Single Node pNFS Server
References: <4F2D6B97.6050102@RedHat.com>
In-Reply-To: <4F2D6B97.6050102@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Steve!

The required config options are:
CONFIG_NFSD_V4=y
CONFIG_PNFSD=y
CONFIG_PNFSD_LOCAL_EXPORT=y

The following config options are optional and may break your client:
CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS=y
CONFIG_PNFSD_LEXP_LAYOUT_SEGMENT_SIZE=65536

Benny

On 2012-02-04 19:32, Steve Dickson wrote:
> Hello all,
> 
> To help with the testing of pNFS clients, I making 
> available a single node pNFS server (the  pnfsd-lexp 
> branch of Benny's git tree) in Fedora based kernel 
> and nfs-utils RPMs. This server only supports file layouts. 
> 
> Your need to be running a Fedora 16 to use these RPMs.
> The RPMs are in a yum repository. Download this repo:
> 
>    http://steved.fedorapeople.org/pnfs.repo
> and then do a yum update on a F16 machine.
> 
> Or you can access the RPMs directly at 
>     http://steved.fedorapeople.org/repos/pnfs/devel/
> 
> The patches used to create the RPMs ar at:
>     http://steved.fedorapeople.org/repos/pnfs/devel/pnfsd-3.3.0-0.rc2.git1.1.patch
>     http://steved.fedorapeople.org/repos/pnfs/devel/pnfs-export-1.2.5-11.patch
> 
> Happy hunting! 
> 
> steved.
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
