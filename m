Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29210 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292Ab3J2Ml3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 08:41:29 -0400
Message-ID: <526FACE5.5040805@netapp.com>
Date: Tue, 29 Oct 2013 08:41:09 -0400
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <trond.myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Use WRITE_PLUS for hole punches
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com> <1382972418-2249-2-git-send-email-bjschuma@netapp.com> <20131029073908.GC10889@infradead.org>
In-Reply-To: <20131029073908.GC10889@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 29 Oct 2013 03:39:08 AM EDT, Christoph Hellwig wrote:
> On Mon, Oct 28, 2013 at 11:00:16AM -0400, Anna Schumaker wrote:
>> This patch implements a version of fallocate for NFS v4.  In the v4.2
>> case, we use WRITE_PLUS with DATA_CONTENT_HOLE set to punch a hole in a
>> file.  In NFS < v4.2, we fall back to the generic VFS fallocate
>> implementation.
>
> What generic VFS fallocate implementation do you fall back to?  Not only
> can't I find a call to to it, nor does such a thing even exist.
>

Hmm... good question.  I'm not sure what I was thinking when I wrote 
that comment, so I'll remove it for v2 of these patches.
