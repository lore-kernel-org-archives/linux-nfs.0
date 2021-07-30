Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B211CC432BE
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Jul 2021 00:31:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9C7D16103A
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Jul 2021 00:31:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231520AbhG3Ab2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Jul 2021 20:31:28 -0400
Received: from zeniv-ca.linux.org.uk ([142.44.231.140]:42764 "EHLO
        zeniv-ca.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231181AbhG3Ab1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jul 2021 20:31:27 -0400
Received: from viro by zeniv-ca.linux.org.uk with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1m9GQi-0052xR-6k; Fri, 30 Jul 2021 00:31:12 +0000
Date:   Fri, 30 Jul 2021 00:31:12 +0000
From:   Al Viro <viro@zeniv.linux.org.uk>
To:     NeilBrown <neilb@suse.de>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Josef Bacik <josef@toxicpanda.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 04/11] VFS: export lookup_mnt()
Message-ID: <YQNIUA6NKmSgdawv@zeniv-ca.linux.org.uk>
References: <162742539595.32498.13687924366155737575.stgit@noble.brown>
 <162742546551.32498.5847026750506620683.stgit@noble.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162742546551.32498.5847026750506620683.stgit@noble.brown>
Sender: Al Viro <viro@ftp.linux.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jul 28, 2021 at 08:37:45AM +1000, NeilBrown wrote:
> In order to support filehandle lookup in filesystems with internal
> mounts (multiple subvols in the one filesystem) reconnect_path() in
> exportfs will need to find out if a given dentry is already mounted.
> This can be done with the function lookup_mnt(), so export that to make
> it available.

IMO having exportfs modular is wrong - note that fs/fhandle.c is
	* calling functions in exportfs
	* non-modular
	* ... and not going to be modular, no matter what - there
are syscalls in it.
