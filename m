Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aa.linuxbox.com ([69.128.83.226]:2128 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbcBARls (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 12:41:48 -0500
Date: Mon, 1 Feb 2016 12:31:22 -0500 (EST)
From: "Matt W. Benjamin" <matt@cohortfs.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1329865363.28.1454347882962.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1454347277-10997-14-git-send-email-trond.myklebust@primarydata.com>
Subject: Re: [RFC PATCH v3 13/13] pnfs/NFSv4.1: Add multipath capabilities
 to pNFS flexfiles servers over NFSv3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

----- "Trond Myklebust" <trond.myklebust@primarydata.com> wrote:

> This adds multipathing to pNFS over NFSv3 as described in the
> flexfiles
> draft spec.
> Ideally, we'd like to do the same for pNFS files, but the NFSv4.1
> protocol
> requires a call to EXCHANGE_ID in order to test that the connection
> can do
> session trunking.

What is the barrier to sending this to data servers as needed?

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/pnfs_nfs.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 

Matt

-- 
Matt Benjamin
CohortFS, LLC.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://cohortfs.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
