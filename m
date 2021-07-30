Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E779EC43214
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Jul 2021 06:09:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D10D961008
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Jul 2021 06:09:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237244AbhG3GJJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Jul 2021 02:09:09 -0400
Received: from smtp-out1.suse.de ([195.135.220.28]:56552 "EHLO
        smtp-out1.suse.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237163AbhG3GJI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jul 2021 02:09:08 -0400
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 24EBD22129;
        Fri, 30 Jul 2021 06:09:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1627625343; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=yJ1yHepxiXGKkkLe9+dCqnP+TH4u121Dr/zgR8/UQ4o=;
        b=llbq3B68GW9PwFU0onMKrS70kKE/43Vyo2E08QmCsqCYnXkGR5Nwzohzz2RhqT82eYD6Ec
        +R5ms3TKVu9NYv4It5nzVBs0PAOWjK7h9IX99rOv5QR2j3M7xyJ+FOOvzDmPDlP2YCL+Ir
        scRNHrN1Q0mjalav6uXeW8rmPJ8RWwQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1627625343;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=yJ1yHepxiXGKkkLe9+dCqnP+TH4u121Dr/zgR8/UQ4o=;
        b=elmUwU/oy3Wiei721hct2JCqOru8absqb4s/VGNf2JugJzjWpfssezxvIDXtRnzRvgCLFl
        Phhskarx1WBfhOAw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 3655313BFA;
        Fri, 30 Jul 2021 06:08:59 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id FMjSOHuXA2HpAwAAMHmgww
        (envelope-from <neilb@suse.de>); Fri, 30 Jul 2021 06:08:59 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Al Viro" <viro@zeniv.linux.org.uk>
Cc:     "Josef Bacik" <josef@toxicpanda.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Christoph Hellwig" <hch@infradead.org>,
        "Chuck Lever" <chuck.lever@oracle.com>, "Chris Mason" <clm@fb.com>,
        "David Sterba" <dsterba@suse.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH/RFC 00/11] expose btrfs subvols in mount table correctly
In-reply-to: <YQNEK48+GLDvOx8t@zeniv-ca.linux.org.uk>
References: <162742539595.32498.13687924366155737575.stgit@noble.brown>,
 <20210728193536.GD3152@fieldses.org>,
 <e75ccfd2-e09f-99b3-b132-3bd69f3c734c@toxicpanda.com>,
 <YQNEK48+GLDvOx8t@zeniv-ca.linux.org.uk>
Date:   Fri, 30 Jul 2021 16:08:57 +1000
Message-id: <162762533738.21659.10411397768851876517@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 30 Jul 2021, Al Viro wrote:
> On Wed, Jul 28, 2021 at 05:30:04PM -0400, Josef Bacik wrote:
>=20
> > I don't think anybody has that many file systems.  For btrfs it's a single
> > file system.  Think of syncfs, it's going to walk through all of the super
> > blocks on the system calling ->sync_fs on each subvol superblock.  Now th=
is
> > isn't a huge deal, we could just have some flag that says "I'm not real" =
or
> > even just have anonymous superblocks that don't get added to the global
> > super_blocks list, and that would address my main pain points.
>=20
> Umm...  Aren't the snapshots read-only by definition?

No, though they can be.
subvols can be created empty, or duplicated from an existing subvol.
Any subvol can be written, using copy-on-write of course.

NeilBrown
