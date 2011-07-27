Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:51723 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab1G0VJm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 17:09:42 -0400
Message-ID: <4E307E6F.6090309@panasas.com>
Date: Wed, 27 Jul 2011 14:09:03 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v3 03/25] NFS41: Let layoutcommit handle multiple segments
References: <1311792048-12551-1-git-send-email-rees@umich.edu> <1311792048-12551-4-git-send-email-rees@umich.edu> <4E306F84.6030808@panasas.com> <1311798159.25645.32.camel@lade.trondhjem.org> <4E30762E.4000508@panasas.com> <20110727205804.GA13698@merit.edu>
In-Reply-To: <20110727205804.GA13698@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 01:58 PM, Jim Rees wrote:
>   But I thought for simplicity since this patchset was reviewed then, I've
>   tested with this patch and it works good as well. If you are going to
>   break things up, I can test with the minimal patches and report what is
>   need in Stable. (Is anyone working on it?)
> 
> We may have over-squashed that one for block layout.  I can dig up the
> original patches if necessary, but I'm guessing you probably have them.

Please do. Because by now I'm confused. the first I discovered it was
by git diff of a branch that worked. I lost tracked of where the code
was originated from.

But Trond just for simplicity sake can't we just submit the patch as is.
It is all related to layoutcommit breakage and it is all bits that we
eventually need. both objects and blocks (and files when they do segments).
I don't think it is that "too bloated" that it can't be sent to stable.
What are the risks you are anticipating?

Thanks
Boaz
