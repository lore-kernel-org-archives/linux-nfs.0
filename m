Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A4EFC432BE
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Aug 2021 21:10:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DDA8E60F70
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Aug 2021 21:10:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231623AbhHBVLE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Aug 2021 17:11:04 -0400
Received: from smtp-out1.suse.de ([195.135.220.28]:33838 "EHLO
        smtp-out1.suse.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231583AbhHBVLE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2021 17:11:04 -0400
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 44F992203F;
        Mon,  2 Aug 2021 21:10:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1627938653; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=dHZ2/Ll07WD3olUgwvKGtR6FEX0tCoDoGg2V3LwKtZ4=;
        b=QuVc1ErVArVvsHnPBQm4qXMVNWi/ZTPC9bdyQCgHp09Z1EfR952Er9s0kwx9RGJfNKvCpV
        L3A5qKOL+pK4WLoMTrzoiS5+yKzSZhkNxPXkbW6Au03AYJhYBW2wEJ8NmsqJVBerTHQ0+W
        h8rgDqOLpIQMWueNq0tsQGReCbtWNLQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1627938653;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=dHZ2/Ll07WD3olUgwvKGtR6FEX0tCoDoGg2V3LwKtZ4=;
        b=Ez8aOmzaReHigzMq1fV5mt18VOOJo3cgIoDe8RmzWoDHmKqUaXsKLVDcoM3Ger946oB5g3
        D0bc8P4yhKn2gMBQ==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 1FCC413CAE;
        Mon,  2 Aug 2021 21:10:49 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id baPSM1lfCGGefwAAMHmgww
        (envelope-from <neilb@suse.de>); Mon, 02 Aug 2021 21:10:49 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "Miklos Szeredi" <miklos@szeredi.hu>,
        "Al Viro" <viro@zeniv.linux.org.uk>,
        "Christoph Hellwig" <hch@infradead.org>,
        "Josef Bacik" <josef@toxicpanda.com>,
        "Chuck Lever" <chuck.lever@oracle.com>, "Chris Mason" <clm@fb.com>,
        "David Sterba" <dsterba@suse.com>, linux-fsdevel@vger.kernel.org,
        "Linux NFS list" <linux-nfs@vger.kernel.org>,
        "Btrfs BTRFS" <linux-btrfs@vger.kernel.org>
Subject: Re: A Third perspective on BTRFS nfsd subvol dev/inode number issues.
In-reply-to: <20210802123930.GA6890@fieldses.org>
References: <162742539595.32498.13687924366155737575.stgit@noble.brown>,
 <162742546548.32498.10889023150565429936.stgit@noble.brown>,
 <YQNG+ivSssWNmY9O@zeniv-ca.linux.org.uk>,
 <162762290067.21659.4783063641244045179@noble.neil.brown.name>,
 <CAJfpegsR1qvWAKNmdjLfOewUeQy-b6YBK4pcHf7JBExAqqUvvg@mail.gmail.com>,
 <162762562934.21659.18227858730706293633@noble.neil.brown.name>,
 <CAJfpegtu3NKW9m2jepRrXe4UTuD6_3k0Y6TcCBLSQH7SSC90BA@mail.gmail.com>,
 <162763043341.21659.15645923585962859662@noble.neil.brown.name>,
 <CAJfpegub4oBZCBXFQqc8J-zUiSW+KaYZLjZaeVm_cGzNVpxj+A@mail.gmail.com>,
 <162787790940.32159.14588617595952736785@noble.neil.brown.name>,
 <20210802123930.GA6890@fieldses.org>
Date:   Tue, 03 Aug 2021 07:10:44 +1000
Message-id: <162793864421.32159.6348977485257143426@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 02 Aug 2021, J. Bruce Fields wrote:
> On Mon, Aug 02, 2021 at 02:18:29PM +1000, NeilBrown wrote:
> > For btrfs, the "location" is root.objectid ++ file.objectid.  I think
> > the inode should become (file.objectid ^ swab64(root.objectid)).  This
> > will provide numbers that are unique until you get very large subvols,
> > and very many subvols.
> 
> If you snapshot a filesystem, I'd expect, at least by default, that
> inodes in the snapshot to stay the same as in the snapshotted
> filesystem.

As I said: we need to challenge and revise user-space (and meat-space)
expectations. 

In btrfs, you DO NOT snapshot a FILESYSTEM.  Rather, you effectively
create a 'reflink' for a subtree (only works on subtrees that have been
correctly created with the poorly named "btrfs subvolume" command).

As with any reflink, the original has the same inode number that it did
before, the new version has a different inode number (though in current
BTRFS, half of the inode number is hidden from user-space, so it looks
like the inode number hasn't changed).

NeilBrown
