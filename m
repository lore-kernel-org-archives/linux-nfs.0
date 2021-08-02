Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 937C0C4338F
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Aug 2021 12:39:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6F3F560F50
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Aug 2021 12:39:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232629AbhHBMjm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Aug 2021 08:39:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49536 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233663AbhHBMjm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2021 08:39:42 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E38C3C061760;
        Mon,  2 Aug 2021 05:39:32 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id CF8D47C76; Mon,  2 Aug 2021 08:39:30 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org CF8D47C76
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1627907970;
        bh=zCce8ftdowQfi/L0q1jftMiDBXO9PLSkq+vXt4GZinM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=QGgVB4gwWgoiHBQM32jc7PjhkyETv3VD79IRBNfP8qCVrB+6Lrjmzqu6wLZodqfF3
         ybMrKBrEZf7Rz1Yi6Vo1YiMLSG611FMqAyyQVa1psZzHtjF3y35z62whdBi2S1+RqC
         qA2u9NqkDqRwwABpsjEw0B3lN2dA+lvoxm19I2fk=
Date:   Mon, 2 Aug 2021 08:39:30 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.de>
Cc:     Miklos Szeredi <miklos@szeredi.hu>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Josef Bacik <josef@toxicpanda.com>,
        Chuck Lever <chuck.lever@oracle.com>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>, linux-fsdevel@vger.kernel.org,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Btrfs BTRFS <linux-btrfs@vger.kernel.org>
Subject: Re: A Third perspective on BTRFS nfsd subvol dev/inode number issues.
Message-ID: <20210802123930.GA6890@fieldses.org>
References: <162742539595.32498.13687924366155737575.stgit@noble.brown>
 <162742546548.32498.10889023150565429936.stgit@noble.brown>
 <YQNG+ivSssWNmY9O@zeniv-ca.linux.org.uk>
 <162762290067.21659.4783063641244045179@noble.neil.brown.name>
 <CAJfpegsR1qvWAKNmdjLfOewUeQy-b6YBK4pcHf7JBExAqqUvvg@mail.gmail.com>
 <162762562934.21659.18227858730706293633@noble.neil.brown.name>
 <CAJfpegtu3NKW9m2jepRrXe4UTuD6_3k0Y6TcCBLSQH7SSC90BA@mail.gmail.com>
 <162763043341.21659.15645923585962859662@noble.neil.brown.name>
 <CAJfpegub4oBZCBXFQqc8J-zUiSW+KaYZLjZaeVm_cGzNVpxj+A@mail.gmail.com>
 <162787790940.32159.14588617595952736785@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162787790940.32159.14588617595952736785@noble.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Aug 02, 2021 at 02:18:29PM +1000, NeilBrown wrote:
> For btrfs, the "location" is root.objectid ++ file.objectid.  I think
> the inode should become (file.objectid ^ swab64(root.objectid)).  This
> will provide numbers that are unique until you get very large subvols,
> and very many subvols.

If you snapshot a filesystem, I'd expect, at least by default, that
inodes in the snapshot to stay the same as in the snapshotted
filesystem.

--b.
