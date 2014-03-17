Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933112AbaCQOj5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2014 10:39:57 -0400
Message-ID: <5327093B.1090109@RedHat.com>
Date: Mon, 17 Mar 2014 10:39:55 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] command line IPv6 support for exportfs
References: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
In-Reply-To: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/12/2014 01:47 PM, Chuck Lever wrote:
> Though /etc/exports can contain IPv6 literals as client names, the
> exportfs command doesn't allow an IPv6 literal when adding or
> removing a temporary export.
> 
>   exportfs [-u] client:/path
> 
> If "client" is an IPv6 presentation address, it contains colons.
> The problem is that exportfs already uses a colon to separate the
> client identifier from the export pathname.
> 
> To escape colons in the client name, adopt the same mechanism that
> is used for mount.nfs.  Users wrap IPv6 literals in square brackets.
> 
> exportfs has to be a little more complicated than mount.nfs,
> however.  It must still be able to distinguish hostname wildcards
> that use brackets, and be able to deal with network address
> prefixes.
> 
> With this patch series,
> 
>   [abc]-machine.example.org:/export
> 
>   192.168.76.16:/share
> 
>   [2604:8800:100:81fc:82ee:73ff:fe43:d64f]:/export/home
> 
>   [fe80::]/64:/var/tmp
> 
> are now all accepted by exportfs.
> 
> ---
> 
> Chuck Lever (2):
>       exportfs: Refactor exportfs() and unexportfs()
>       exportfs: Support raw IPv6 addresses with "client:/path"
Both were committed...

steved.

> 
> 
>  utils/exportfs/exportfs.c   |  134 ++++++++++++++++++++++++++++++++++++-------
>  utils/exportfs/exportfs.man |   16 +++++
>  2 files changed, 127 insertions(+), 23 deletions(-)
> 
