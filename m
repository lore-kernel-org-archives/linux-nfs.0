Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,MAILING_LIST_MULTI,
	PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89CBAC4743C
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Jun 2021 14:40:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 62E64610C7
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Jun 2021 14:40:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229807AbhFUOmv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 21 Jun 2021 10:42:51 -0400
Received: from mta-101a.oxsus-vadesecure.net ([51.81.61.60]:51429 "EHLO
        oxsus1nmtao01p.internal.vadesecure.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S229765AbhFUOmv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2021 10:42:51 -0400
X-Greylist: delayed 314 seconds by postgrey-1.27 at vger.kernel.org; Mon, 21 Jun 2021 10:42:51 EDT
DKIM-Signature: v=1; a=rsa-sha256; bh=/65HdiEyg1ggpFdUR6NllUZtiOgzL7wsnWkVj/
 Ja13E=; c=relaxed/relaxed; d=earthlink.net; h=from:reply-to:subject:
 date:to:cc:resent-date:resent-from:resent-to:resent-cc:in-reply-to:
 references:list-id:list-help:list-unsubscribe:list-subscribe:list-post:
 list-owner:list-archive; q=dns/txt; s=dk12062016; t=1624286106;
 x=1624890906; b=AQeH2LG2oJx6wf9UVK+u2kD4uNbUAxQOYppxX4WDExGNfGWlsLX9Skg
 bcXsFF6shq/zgzGfNV2HcmDGc7mB3f0vQW8BjXIsRwXuwcw5eXi6SKNCJsd0YpvLXH71b/O
 5/bsC2VeoH5SCTnU9yTGdh7gmk8w2VbxAT5744E9Jwiu11wV7llk8o4/Gnruk9q10GooBXB
 mKq0y4QvFqe6SQ9zRUH+yjS2Huu9uojH4xYWTV0+G3RebrHgoOaavSYZqO59fFXzKNxtZce
 hhdfUmvmaSGoiYB3j1VnUV+EyxTxL46XszTXARdAwJtsryfA1E0zveMuop/mkw/aZ+fwOt0
 r8g==
Received: from FRANKSTHINKPAD ([76.105.143.216])
 by oxsus1nmtao01p.internal.vadesecure.com with ngmta
 id ea035de9-168a9f9b74b8bc05; Mon, 21 Jun 2021 14:35:05 +0000
From:   "Frank Filz" <ffilzlnx@mindspring.com>
To:     "'NeilBrown'" <neilb@suse.de>,
        "'Wang Yugui'" <wangyugui@e16-tech.com>
Cc:     <linux-nfs@vger.kernel.org>
References: <20210617122852.BE6A.409509F4@e16-tech.com>, <162397637680.29912.2268876490205517592@noble.neil.brown.name>, <20210618152631.F3DE.409509F4@e16-tech.com> <162425113589.17441.4163890972298681569@noble.neil.brown.name>
In-Reply-To: <162425113589.17441.4163890972298681569@noble.neil.brown.name>
Subject: RE: any idea about auto export multiple btrfs snapshots?
Date:   Mon, 21 Jun 2021 07:35:05 -0700
Message-ID: <000001d766aa$a16b3470$e4419d50$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailer: Microsoft Outlook 15.0
Thread-Index: AQGgjb0JmyjTlu+qHq6E792GRQrYXwDUVoz+AX4+uU8CMxYmZKtoCsXQ
Content-Language: en-us
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> I think the problem is that the submount doesn't appear in =
/proc/mounts.
> "nfsd_fh()" in nfs-utils needs to be able to map from the uuid for a =
filesystem to
> the mount point.  To do this it walks through /proc/mounts checking =
the uuid of
> each filesystem.  If a filesystem isn't listed there, it obviously =
fails.
>=20
> I guess you could add code to nfs-utils to do whatever "btrfs subvol =
list" does to
> make up for the fact that btrfs doesn't register in /proc/mounts.
>=20
> NeilBrown

I've been watching this with interest for the nfs-ganesha project. We =
recently were made aware that we weren't working with btrfs subvols, and =
I added code so that in addition to using getmntent (essentially =
/proc/mounts) to populate filesystems, we also scan for btrfs subvols =
and with that we are able to export subvols. My question is does a =
snapshot look any different than a subvol? If they show up in the subvol =
list then we shouldn't need to do anything more for nfs-ganesha, but if =
there's something else needed to discover them, then we may need =
additional code in nfs-ganesha. I have not yet had a chance to check out =
exporting a snapshot yet.

Thanks

Frank Filz

