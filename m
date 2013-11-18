Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:11830 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511Ab3KRRu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 12:50:26 -0500
Message-ID: <528A5360.4000206@netapp.com>
Date: Mon, 18 Nov 2013 12:50:24 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trondmy@gmail.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix kbuild errors due to missing symbols
References: <1384554636-25330-1-git-send-email-bjschuma@netapp.com> <1384557410.3222.2.camel@leira.trondhjem.org>
In-Reply-To: <1384557410.3222.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-7"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/15/2013 06:16 PM, Trond Myklebust wrote:
> On Fri, 2013-11-15 at 17:30 -0500, Anna Schumaker wrote:
>> My recent patch 644aa303: "NFS: Enabling v4.2 should not recompile nfsd
>> and lockd" caused build errors when CONFIG_NFS_USE_LEGACY_DNS=y and when
>> CONFIG_NFS_V4=n.  This patch fixes those errors.
>>
> 
> Wait... 
> 
>         config NFS_USE_LEGACY_DNS
>                 bool "Use the legacy NFS DNS resolver"
>                 depends on NFS_V4
>                 help
>                   The kernel now provides a method for translating a host name into an
>                   IP address.  Select Y here if you would rather use your own DNS
>                   resolver script.
>         
>                   If unsure, say N
>         
>         config NFS_USE_KERNEL_DNS
>                 bool
>                 depends on NFS_V4 && !NFS_USE_LEGACY_DNS
>                 select DNS_RESOLVER
>                 default y
> 
> How can that result in NFS_V4=n && NFS_USE_LEGACY_DNS=y?
> 

It's a poorly phrased commit message, actually.  I meant that just setting CONFIG_NFS_USE_LEGACY_DNS=y causes build problems, and then setting CONFIG_NFS_V4=n causes a different set of errors.
