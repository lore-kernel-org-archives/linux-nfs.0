Return-Path: <SRS0=x/41=5L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE50AC43331
	for <linux-nfs@archiver.kernel.org>; Thu, 26 Mar 2020 19:03:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7833620719
	for <linux-nfs@archiver.kernel.org>; Thu, 26 Mar 2020 19:03:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="qxb+5/tn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727192AbgCZTDR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 26 Mar 2020 15:03:17 -0400
Received: from smtp-o-3.desy.de ([131.169.56.156]:36537 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726496AbgCZTDQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Mar 2020 15:03:16 -0400
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
        by smtp-o-3.desy.de (Postfix) with ESMTP id 64DF16049D
        for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2020 20:03:14 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 64DF16049D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1585249394; bh=v910PNI4OnJ6Njsd9SRTmzsJcZEqYnktsPpV2maBiHc=;
        h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
        b=qxb+5/tnU8cZLkwHs+Ezvt0HDmsyRIpezu93jQFlmKkc9jfe5CTc4mDQM2UYmOVlx
         N6sFrBAKzseOqBg2tpTPMzOWEslJzY3BSD1zEyI3py8ffNtMvZ5ZeLqiODEFyr+DJS
         gbA+2fZz7RpY+2QQGbTHu3YhWQ7LsTienEFGuFdE=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [131.169.56.131])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 589E1A00B3;
        Thu, 26 Mar 2020 20:03:14 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-2.desy.de (Postfix) with ESMTP id 2FF1F100076;
        Thu, 26 Mar 2020 20:03:14 +0100 (CET)
Date:   Thu, 26 Mar 2020 20:03:13 +0100 (CET)
From:   "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To:     Frank van der Linden <fllinden@amazon.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Message-ID: <1885904737.8217161.1585249393750.JavaMail.zimbra@desy.de>
In-Reply-To: <20200325231051.31652-1-fllinden@amazon.com>
References: <20200325231051.31652-1-fllinden@amazon.com>
Subject: Re: [PATCH v2 00/13] NFS client user xattr (RFC8276) support
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 8.8.15_GA_3901 (ZimbraWebClient - FF74 (Linux)/8.8.15_GA_3895)
Thread-Topic: NFS client user xattr (RFC8276) support
Thread-Index: KvqUgEw5xowS7eTlF5AaiMw/U7jCcA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Frank.

----- Original Message -----
> From: "Frank van der Linden" <fllinden@amazon.com>
> To: "linux-nfs" <linux-nfs@vger.kernel.org>, "Anna Schumaker" <anna.schumaker@netapp.com>, "Trond Myklebust"
> <trond.myklebust@hammerspace.com>
> Cc: "Frank van der Linden" <fllinden@amazon.com>
> Sent: Thursday, March 26, 2020 12:10:38 AM
> Subject: [PATCH v2 00/13] NFS client user xattr (RFC8276) support

> v1 is here: https://www.spinics.net/lists/linux-nfs/msg76740.html
> 
> v2:
> 
> * Move nfs4 specific definitions to nfs_fs4.h
> * Squash some patches together to avoid unused function warnings
>  when bisecting.
> * Made determining server support a two-step process. First,
>  the extended attribute FATTR is verified to be supported, then
>  the value of the attributed is queried in fsinfo to determine
>  support.

The new patchset looks broken to me.

Client quiryes for supported attributes and gets xattr_support bit set:

Mar 26 11:27:07 ani.desy.de kernel: decode_attr_supported: bitmask=fcffbfff:40fdbe3e:00040800

However, the attribute never queries, but client makes is decision:

Mar 26 11:27:07 ani.desy.de kernel: decode_attr_xattrsupport: XATTR support=false

The packets can be found here: https://sas.desy.de/index.php/s/GEPiBxPg3eR4aGA

Can you provide packets of your mount/umount round.

Regards,
   Tigran.


> * Fixed up Makefile to remove an unneeded extra line.
> 
> This was tested as before (using my own stress tests), but also
> with xfstests-dev. No issues were found, but xfstests needs some
> fixes to correctly run the applicable xattr tests on NFS. I
> have those changes, but need to send them out.
> 
> I also tested stress-ng-xattr with 1000 workers on the client
> side, running for 8 hours without problems (except for noting
> that the session tbl_lock can become quite hot when doing
> NFS operations by 1000 threads, but that's a separate issue).
> 
> 
> Frank van der Linden (13):
>  nfs,nfsd:  NFSv4.2 extended attribute protocol definitions
>  nfs: add client side only definitions for user xattrs
>  NFSv4.2: define limits and sizes for user xattr handling
>  NFSv4.2: query the server for extended attribute support
>  NFSv4.2: add client side XDR handling for extended attributes
>  nfs: define nfs_access_get_cached function
>  NFSv4.2: query the extended attribute access bits
>  nfs: modify update_changeattr to deal with regular files
>  nfs: define and use the NFS_INO_INVALID_XATTR flag
>  nfs: make the buf_to_pages_noslab function available to the nfs code
>  NFSv4.2: add the extended attribute proc functions.
>  NFSv4.2: hook in the user extended attribute handlers
>  NFSv4.2: add client side xattr caching.
> 
> fs/nfs/Makefile             |    2 +-
> fs/nfs/client.c             |   22 +-
> fs/nfs/dir.c                |   24 +-
> fs/nfs/inode.c              |   16 +-
> fs/nfs/nfs42.h              |   24 +
> fs/nfs/nfs42proc.c          |  248 ++++++++
> fs/nfs/nfs42xattr.c         | 1083 +++++++++++++++++++++++++++++++++++
> fs/nfs/nfs42xdr.c           |  438 ++++++++++++++
> fs/nfs/nfs4_fs.h            |   35 ++
> fs/nfs/nfs4client.c         |   31 +
> fs/nfs/nfs4proc.c           |  237 +++++++-
> fs/nfs/nfs4super.c          |   10 +
> fs/nfs/nfs4xdr.c            |   31 +
> fs/nfs/nfstrace.h           |    3 +-
> include/linux/nfs4.h        |   25 +
> include/linux/nfs_fs.h      |   12 +
> include/linux/nfs_fs_sb.h   |    6 +
> include/linux/nfs_xdr.h     |   60 +-
> include/uapi/linux/nfs4.h   |    3 +
> include/uapi/linux/nfs_fs.h |    1 +
> 20 files changed, 2269 insertions(+), 42 deletions(-)
> create mode 100644 fs/nfs/nfs42xattr.c
> 
> --
> 2.17.2
