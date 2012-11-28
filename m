Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54853 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755404Ab2K1OsZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 09:48:25 -0500
Date: Wed, 28 Nov 2012 09:48:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/2] nfsd: containerise NFSv4 recovery state
Message-ID: <20121128144821.GC11651@fieldses.org>
References: <20121126131404.8822.65870.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121126131404.8822.65870.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 04:16:18PM +0300, Stanislav Kinsbursky wrote:
> This patch set makes rec_file and in_grace global static variables allocated
> per network namespace.
> Both of them are a part of client tracking engine, which is containerised
> already.

Thanks, applying for 3.8.--b.

> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (2):
>       nfsd: recovery - make rec_file per net
>       nfsd: recovery - make in_grace per net
> 
> 
>  fs/nfsd/netns.h       |    3 ++
>  fs/nfsd/nfs4recover.c |   79 ++++++++++++++++++++++++-------------------------
>  2 files changed, 42 insertions(+), 40 deletions(-)
> 
