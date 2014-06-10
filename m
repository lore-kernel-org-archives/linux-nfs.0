Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaFJPEM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2014 11:04:12 -0400
Message-ID: <53971E68.3060200@RedHat.com>
Date: Tue, 10 Jun 2014 11:04:08 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: andros@netapp.com, trond.myklebust@primarydata.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFS: Fix SECINFO processing regression
References: <1402342401-5640-1-git-send-email-andros@netapp.com>
In-Reply-To: <1402342401-5640-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/09/2014 03:33 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Iterate over multiple flavors returned by SECINFO. If RPC_AUTH_GSS is in the
> secinfo list, fully test (get and auth, credential, and gss_context)
> 
> Fix some error paths.
> 
> Testing: Minimal testing of the nfs_test_gss_flavor. Will run more tests after
> the June 2014 bakeathon
> 
> Note: Can supply a patch for SECINFO_NO_name to use nfs4_negotiate_security.
> 
> Andy Adamson (3):
>   NFS check the return of nfs4_negotiate_security in nfs4_submount
>   NFS Return -EPERM if no supported or matching SECINFO flavor
>   NFS test SECINFO RPC_AUTH_GSS pseudoflavors for support
> 
>  fs/nfs/nfs4namespace.c | 66 +++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 55 insertions(+), 11 deletions(-)
> 
Tested-By: Steve Dickson <steved@redhat.com>

