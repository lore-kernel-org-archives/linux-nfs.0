Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60584 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932726AbbHJVWQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2015 17:22:16 -0400
Date: Mon, 10 Aug 2015 17:22:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/5] NFSD: some bugfixes and updates
Message-ID: <20150810212216.GF10455@fieldses.org>
References: <55BA2B46.90204@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55BA2B46.90204@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 09:48:54PM +0800, Kinglong Mee wrote:
> The first three are bugfixes, the last two are updates for EXCLUSIVE4_1.

These all look good to me, thanks, applying.--b.

> 
> Kinglong Mee (5):
>   NFSD: Store parent's stat in a sperate value
>   NFSD: Fix a encode bug of FS_LAYOUT_TYPES and LAYOUT_TYPES
>   NFSD: SUPPATTR_EXCLCREAT must be encoded before SECURITY_LABEL.
>   NFSD: Set the attributes used to store the verifier for EXCLUSIVE4_1
>   NFSD: Return word2 bitmask if setting security label in OPEN/CREATE
> 
>  fs/nfsd/nfs4proc.c |  12 ++--
>  fs/nfsd/nfs4xdr.c  | 158 +++++++++++++++++++++++++++++++++--------------------
>  fs/nfsd/vfs.c      |   6 --
>  fs/nfsd/vfs.h      |   6 ++
>  4 files changed, 112 insertions(+), 70 deletions(-)
> 
> -- 
> 2.4.3
