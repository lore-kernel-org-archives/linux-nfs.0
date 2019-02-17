Return-Path: <SRS0=2fom=QY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3397C10F00
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 00:11:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B2918222A3
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 00:11:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727577AbfBQALz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Feb 2019 19:11:55 -0500
Received: from zeniv.linux.org.uk ([195.92.253.2]:52678 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726386AbfBQALz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Feb 2019 19:11:55 -0500
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.91 #2 (Red Hat Linux))
        id 1gvA3k-0002Ti-E0; Sun, 17 Feb 2019 00:11:52 +0000
Date:   Sun, 17 Feb 2019 00:11:52 +0000
From:   Al Viro <viro@zeniv.linux.org.uk>
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 08/27] containers, vfs: Honour
 CONTAINER_NEW_EMPTY_FS_NS
Message-ID: <20190217001152.GR2217@ZenIV.linux.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <155024690964.21651.13823458384398366556.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155024690964.21651.13823458384398366556.stgit@warthog.procyon.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 15, 2019 at 04:08:29PM +0000, David Howells wrote:

> +	mnt_ns = alloc_mnt_ns(container->cred->user_ns, false);
> +	if (IS_ERR(mnt_ns)) {
> +		ret = PTR_ERR(mnt_ns);
> +		goto out_fd;
> +	}
> +
> +	mnt = real_mount(path->mnt);
> +	mnt_add_count(mnt, 1);
> +	mnt->mnt_ns = mnt_ns;
> +	mnt_ns->root = mnt;
> +	mnt_ns->mounts++;
> +	list_add(&mnt->mnt_list, &mnt_ns->list);
> +
> +	ret = -EBUSY;
> +	spin_lock(&container->lock);
> +	if (!container->ns->mnt_ns) {
> +		container->ns->mnt_ns = mnt_ns;
> +		write_seqcount_begin(&container->seq);
> +		container->root.mnt = path->mnt;
> +		container->root.dentry = path->dentry;
> +		write_seqcount_end(&container->seq);
> +		path_get(&container->root);
> +		mnt_ns = NULL;
> +		ret = 0;
> +	}

Almost certainly buggered.  Assumptions that we _won't_ get
to absolute root of namespace (it's overmounted and we are
chrooted into it, basically) had been made in quite a few
places.  The thing you are creating is *not* like normal
namespaces in that respect.
