Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:35678 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751736Ab0LAPEo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 10:04:44 -0500
Date: Wed, 1 Dec 2010 10:04:28 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Ensure we use the correct cookie in
 nfs_readdir_xdr_filler
Message-ID: <20101201150428.GA2879@elliptictech.com>
References: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-30 22:47 -0500, Trond Myklebust wrote:
> We need to use the cookie from the previous array entry, not the
> actual cookie that we are searching for.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/dir.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)

Indeed, my test script passes with this patch on top of Linus' master,
thanks.  I'll wait for the updated series before trying the other ones.

Tested-by: Nick Bowler <nbowler@elliptictech.com>

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
