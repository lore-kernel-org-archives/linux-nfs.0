Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4689C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:21:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B59B42080F
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:21:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727578AbfCYXVN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 19:21:13 -0400
Received: from fieldses.org ([173.255.197.46]:56082 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726010AbfCYXVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Mar 2019 19:21:13 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 643211C81; Mon, 25 Mar 2019 19:21:13 -0400 (EDT)
Date:   Mon, 25 Mar 2019 19:21:13 -0400
To:     Pei-Feng liu <liupeifeng@horiscale.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Using a larger memory to cache filename when decoding FH
Message-ID: <20190325232113.GB23190@fieldses.org>
References: <1553348794-4505-1-git-send-email-liupeifeng@horiscale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553348794-4505-1-git-send-email-liupeifeng@horiscale.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Mar 23, 2019 at 09:46:33PM +0800, Pei-Feng liu wrote:
> The maximum length of filename string in 'fs/exportfs/expfs.c' is limited to be
> 'NAME_MAX'. But I have a special filesystem driver with longer filename.

That's interesting.  I'm sort of surprised that other parts of the
kernel or libc don't rely on the NAME_MAX assumption.

Anyway, we probably can't consider this for upstream unless the
filesystem driver that needs it is also upstream.

--b.

> When
> exporting it's namespace with NFS, 'exportfs_decode_fh()' can't holds the
> filename if its length is larger than 'NAME_MAX'. And 'dentry' in VFS layer
> doesn't contrain the length of filename within 'NAME_MAX'. I guess the correct
> method is firstly probe the length of filename with 'vfs_statfs()'. With this
> value to malloc a larger enough memory to cache the filename when decoding a FH.
> 
> Pei-Feng liu (1):
>   fs/exportfs: Decoding FH with a larger memory to cache the filename.
> 
>  fs/exportfs/expfs.c | 30 +++++++++++++++++++++++++++++-
>  1 file changed, 29 insertions(+), 1 deletion(-)
> 
> -- 
> 1.8.3.1
