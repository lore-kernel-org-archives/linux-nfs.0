Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44255 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748Ab1AJQp2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 11:45:28 -0500
Subject: Re: [PATCH v4 3/5] NFS: Add secinfo procedure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>,
        "Mr. Steve Dickson" <SteveD@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4D2760D7.3020701@netapp.com>
References: <4D2760D7.3020701@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Jan 2011 11:45:26 -0500
Message-ID: <1294677926.3349.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-01-07 at 13:52 -0500, Bryan Schumaker wrote: 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 4925b22..b4904b2 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -540,6 +540,7 @@ enum {
>  	NFSPROC4_CLNT_SETACL,
>  	NFSPROC4_CLNT_FS_LOCATIONS,
>  	NFSPROC4_CLNT_RELEASE_LOCKOWNER,
> +	NFSPROC4_CLNT_SECINFO,
>  
>  	/* nfs41 */
>  	NFSPROC4_CLNT_EXCHANGE_ID,

Unfortunately, this hunk will break nfsstat. Let's give these patches
one more cycle of testing. I'll carry them in my tree and will follow up
with SteveD to see what we can do about fixing nfsstat. It is annoying
that nfsstat should be required to keep a private copy of the client
operation table, and it keeps biting us every time we want to add some
new NFSv4.0 operation.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

