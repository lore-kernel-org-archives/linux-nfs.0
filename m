Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:45916 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599Ab3KOXZm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 18:25:42 -0500
Received: by mail-ie0-f182.google.com with SMTP id e14so5737557iej.41
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 15:25:42 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH] NFS: Fix kbuild errors due to missing symbols
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <1384557410.3222.2.camel@leira.trondhjem.org>
Date: Fri, 15 Nov 2013 18:25:39 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F23E03C4-BFA2-43AD-9D52-4071280B5126@gmail.com>
References: <1384554636-25330-1-git-send-email-bjschuma@netapp.com> <1384557410.3222.2.camel@leira.trondhjem.org>
To: Anna Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 15, 2013, at 18:16, Trond Myklebust <trondmy@gmail.com> wrote:

> On Fri, 2013-11-15 at 17:30 -0500, Anna Schumaker wrote:
>> My recent patch 644aa303: "NFS: Enabling v4.2 should not recompile nfsd
>> and lockd" caused build errors when CONFIG_NFS_USE_LEGACY_DNS=y and when
>> CONFIG_NFS_V4=n.  This patch fixes those errors.
>> 
> 
> Wait... 
> 
>        config NFS_USE_LEGACY_DNS
>                bool "Use the legacy NFS DNS resolver"
>                depends on NFS_V4
>                help
>                  The kernel now provides a method for translating a host name into an
>                  IP address.  Select Y here if you would rather use your own DNS
>                  resolver script.
> 
>                  If unsure, say N
> 
>        config NFS_USE_KERNEL_DNS
>                bool
>                depends on NFS_V4 && !NFS_USE_LEGACY_DNS
>                select DNS_RESOLVER
>                default y
> 
> How can that result in NFS_V4=n && NFS_USE_LEGACY_DNS=y?

OK. The problem is resolved using an include of nfs_fs.h in the right spot. Will fix…

