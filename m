Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:37862 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758712Ab1EMObX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2011 10:31:23 -0400
In-Reply-To: <20110513103202.GA27578@infradead.org>
References: <1305147805-5756-1-git-send-email-shawn.p.huang@gmail.com>
	<20110513103202.GA27578@infradead.org>
Date: Fri, 13 May 2011 10:31:22 -0400
Message-ID: <BANLkTikeCHBe3OBpuyF6jd_UeF0az0BYcg@mail.gmail.com>
Subject: Re: [PATCH] nfs: check a crash in nfs_lookup_revalidate
From: Peng Huang <shawn.p.huang@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I did not write any code to call lookup_one_len(). I just mounted an
ecryptfs on nfs, and then got the oops. So it should be a problem in
nfs or ecryptfs or both. At least it should not crash.

Peng

On Fri, May 13, 2011 at 6:32 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, May 11, 2011 at 05:03:25PM -0400, Peng Huang wrote:
>> lookup_one_len() may call nfs_loopup_revalidate() with nd == NULL
>> indirectly, that causes the kernel crash.
>
> lookup_one_len must only be called by a filesystem or a library function
> called by the filesystem.  You are not allowed to call it on a random
> filesystem like nfs that doesn't support the underlying assumptions.
>
>
