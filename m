Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36678 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756409AbdEDTJ0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 15:09:26 -0400
Received: by mail-it0-f65.google.com with SMTP id x188so2794168itb.3
        for <linux-nfs@vger.kernel.org>; Thu, 04 May 2017 12:09:26 -0700 (PDT)
Subject: Re: [RFC PATCH 0/5] Fun with the multipathing code
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <e1bee10a-c602-543c-7fee-257cc9f77dcb@gmail.com>
Date: Thu, 4 May 2017 15:09:24 -0400
MIME-Version: 1.0
In-Reply-To: <20170428172535.7945-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'm testing these on two VMs with a single core each, so probably not the use case you had in mind for these patches.  I ran my script that runs connectathon tests on every NFS version, and I'm seeing it consistently takes about a minute longer with "nconnect=2" than it does without the option.

Thanks for working on this!
Anna

On 04/28/2017 01:25 PM, Trond Myklebust wrote:
> In the spirit of experimentation, I've put together a set of patches
> that implement setting up multiple TCP connections to the server.
> The connections all go to the same server IP address, so do not
> provide support for multiple IP addresses (which I believe is
> something Andy Adamson is working on).
> 
> The feature is only enabled for NFSv4.1 and NFSv4.2 for now; I don't
> feel comfortable subjecting NFSv3/v4 replay caches to this
> treatment yet. It relies on the mount option "nconnect" to specify
> the number of connections to st up. So you can do something like
>   'mount -t nfs -overs=4.1,nconnect=8 foo:/bar /mnt'
> to set up 8 TCP connections to server 'foo'.
> 
> Anyhow, feel free to test and give me feedback as to whether or not
> this helps performance on your system.
> 
> Trond Myklebust (5):
>   SUNRPC: Allow creation of RPC clients with multiple connections
>   NFS: Add a mount option to specify number of TCP connections to use
>   NFSv4: Allow multiple connections to NFSv4.x (x>0) servers
>   pNFS: Allow multiple connections to the DS
>   NFS: Display the "nconnect" mount option if it is set.
> 
>  fs/nfs/client.c             |  2 ++
>  fs/nfs/internal.h           |  2 ++
>  fs/nfs/nfs3client.c         |  3 +++
>  fs/nfs/nfs4client.c         | 13 +++++++++++--
>  fs/nfs/super.c              | 12 ++++++++++++
>  include/linux/nfs_fs_sb.h   |  1 +
>  include/linux/sunrpc/clnt.h |  1 +
>  net/sunrpc/clnt.c           | 17 ++++++++++++++++-
>  net/sunrpc/xprtmultipath.c  |  3 +--
>  9 files changed, 49 insertions(+), 5 deletions(-)
> 
