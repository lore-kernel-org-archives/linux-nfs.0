Return-Path: <SRS0=azzX=QQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2A91C282C4
	for <linux-nfs@archiver.kernel.org>; Sat,  9 Feb 2019 21:49:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 74CFB21919
	for <linux-nfs@archiver.kernel.org>; Sat,  9 Feb 2019 21:49:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gipo2Y1o"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726907AbfBIVt3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 9 Feb 2019 16:49:29 -0500
Received: from mail-pf1-f193.google.com ([209.85.210.193]:36143 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726898AbfBIVt3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Feb 2019 16:49:29 -0500
Received: by mail-pf1-f193.google.com with SMTP id n22so608846pfa.3;
        Sat, 09 Feb 2019 13:49:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FiuabyLybc3+NE0GvP6gYKLmctqSddsN8CJIaFvY1yc=;
        b=Gipo2Y1oCnsgkFeyxkcCMacPz49i/Njz4UhPsldY21NHM/3HrSUBqenilRQiI3wZvK
         mKQnfGBc/ZzPAMjf6QThl3BenSFDtYyI+GzTs7ORS4ORpedxMliJJ+28EJzmKzDAHspV
         FpaTlsUGeDayxv3bW03hUslwNZmeE844pvw0vL8fKbozOvphZMAoU0YzLpuRJvUvXhOM
         DA7EYmmTri2aasQTCVhVMA69Pp0WcApWKhKdzCnJnc8CZgO8QGdVT7KQOxPMe5gQ8cjj
         0udIpOqMijK2Ev1e0j5N2kHX9e5qZ9Vv1YsLNrWnjfFlCVNtKBu0bsH3g1BN4HggCyl0
         xIow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=FiuabyLybc3+NE0GvP6gYKLmctqSddsN8CJIaFvY1yc=;
        b=Z0lzmGnouNGcdfyjceycqDIv0Cq/wc1TfaBX4R2pvIIkz3tHPAJZGQ2JrjjLIlc9E/
         hLP6tzrHwGs6aTx8RxXseX+LQazZFzyjuKzZ0r3SmStOrRDxlP7XCaaFjzSPMT1uyrnN
         2vlcNObHzH+fAISWXM4EXcgCVJne5eMomoaqkYK6v4fSJKcjeM9R9X4zXllOMgRaGDLM
         3PEksPJCqQX3UesobwWTJY3l0+Jp/fQCdiXFd3uf7hHzKzre8cuT+Gea+r7gtjWIKJbF
         fCp0j07w35KZouHFO+M66bF7dWR4Nd25jq4zOTWb0IZgTr9CpUGViBtLWqyyp7Zj+gf/
         Erdg==
X-Gm-Message-State: AHQUAub1Lcf3p3ObLPOmm74nqTZmZVtXLSWDqTb2PqHkBsjWJHAxbz4Q
        0PYL9cLJDg4m+x0V8v4PCnAYT/jjURskuAkkAqk=
X-Google-Smtp-Source: AHgI3IbdQOMBKWadO466Ink+yMM5AkI/VRX+74jR8sMNZECEsgDtUtsdsyPqqklLYm5BxcaifrzU0BEQHY6Id45YwJM=
X-Received: by 2002:a62:12d5:: with SMTP id 82mr3535970pfs.255.1549748968184;
 Sat, 09 Feb 2019 13:49:28 -0800 (PST)
MIME-Version: 1.0
References: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
In-Reply-To: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
From:   Steve French <smfrench@gmail.com>
Date:   Sat, 9 Feb 2019 15:49:17 -0600
Message-ID: <CAH2r5mt5wzqKMa3gh_n2KaOORzCj+rkFQh2kCdbDTMBVax3v8A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Containers and distributed filesystems
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "lsf-pc@lists.linux-foundation.org" 
        <lsf-pc@lists.linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        CIFS <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Trond's proposal for discussion (his proposal below) at LSF/MM makes
sense and could be useful, and similar questions come up often with
CIFS/SMB3 (and probably other distributed file systems).

On Wed, Jan 23, 2019 at 12:11 PM Trond Myklebust
<trondmy@hammerspace.com> wrote:
> I'd like to propose an LSF/MM discussion around the topic of containers
> and distributed filesystems.
>
> The background is that we have a number of decisions to make around
> dealing with namespaces when the filesystem is distributed.
>
> On the one hand, there is the issue of which user namespace we should
> be using when putting uids/gids on the wire, or when translating into
> alternative identities (user/group name, cifs SIDs,...). There are two
> main competing proposals: the first proposal is to select the user
> namespace of the process that mounted the distributed filesystem. The
> second proposal is to (continue to) use the user namespace pointed to
> by init_nsproxy. It seems that whichever choice we make, we probably
> want to ensure that all the major distributed filesystems (AFS, CIFS,
> NFS) have consistent handling of these situations.
> Another issue arises around the question of identifying containers when
> they are migrated. At least the NFSv4 client needs to be able to send a
> unique identifier that is preserved across container migration. The
> uts_namespace is typically insufficient for this purpose, since most
> containers don't bother to set a unique hostname.

Makes sense

> Finally, there is an issue that may be unique to NFS (in which case I'd
> be happy to see it as a hallway discussion or a BoF session) around
> preserving file state across container migrations.

Not unique to NFS


-- 
Thanks,

Steve
