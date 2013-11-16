Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53160 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901Ab3KPUMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Nov 2013 15:12:05 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Sat, 16 Nov 2013 20:12:04 +0000
Message-ID: <910547E4-9A70-4258-92C4-233D9DC1C169@netapp.com>
References: <1384527728-1487-1-git-send-email-dros@netapp.com>
 <E1BD19D4-40C6-456D-A6EE-73D3BA2F1E4B@netapp.com>
In-Reply-To: <E1BD19D4-40C6-456D-A6EE-73D3BA2F1E4B@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 16, 2013, at 14:15, Weston Andros Adamson <dros@netapp.com> wrote:

> I'm going to rethink this, as the server may return arbitrarily long bitmaps.
> 
> I'll probably just always allocate an extra page...

Perhaps we should do the same thing for NFSv4 that we do in nfs3_proc_getacl and just have xdr_partial_copy_from_skb allocate the pages for us?

Cheers
  Trond