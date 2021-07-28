Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA465C4338F
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Jul 2021 02:21:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8179B6052B
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Jul 2021 02:21:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233384AbhG1CVl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Jul 2021 22:21:41 -0400
Received: from zeniv-ca.linux.org.uk ([142.44.231.140]:40600 "EHLO
        zeniv-ca.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233223AbhG1CVl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jul 2021 22:21:41 -0400
Received: from viro by zeniv-ca.linux.org.uk with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1m8ZAI-004Ws7-G9; Wed, 28 Jul 2021 02:19:22 +0000
Date:   Wed, 28 Jul 2021 02:19:22 +0000
From:   Al Viro <viro@zeniv.linux.org.uk>
To:     NeilBrown <neilb@suse.de>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Josef Bacik <josef@toxicpanda.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH/RFC 00/11] expose btrfs subvols in mount table correctly
Message-ID: <YQC+qiYVs3NZ7aa5@zeniv-ca.linux.org.uk>
References: <162742539595.32498.13687924366155737575.stgit@noble.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162742539595.32498.13687924366155737575.stgit@noble.brown>
Sender: Al Viro <viro@ftp.linux.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jul 28, 2021 at 08:37:45AM +1000, NeilBrown wrote:

> We can enhance nfsd to understand that some automounts can be managed.
> "internal mounts" where a filesystem provides an automount point and
> mounts its own directories, can be handled differently by nfsd.
> 
> This series addresses all these issues.  After a few enhancements to the
> VFS to provide needed support, they enhance exportfs and nfsd to cope
> with the concept of internal mounts, and then enhance btrfs to provide
> them.

I'm half asleep right now; will review and reply in detail tomorrow.
The first impression is that it's going to be brittle; properties of
mount really should not depend upon the nature of mountpoint - too many
ways for that to go wrong.

Anyway, tomorrow...
