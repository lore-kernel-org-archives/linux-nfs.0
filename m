Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f41.google.com ([209.85.216.41]:35408 "EHLO
	mail-vn0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142AbbE1XGS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 19:06:18 -0400
Received: by vnbf1 with SMTP id f1so6519615vnb.2
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 16:06:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
Date: Thu, 28 May 2015 19:06:17 -0400
Message-ID: <CAHQdGtQyEH9V_XJaQQgPkKGJLy__D0J6cmAHASeEXCZkCCrBjg@mail.gmail.com>
Subject: Re: [RFC v3 42/45] nfs: Add richacl support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 7:04 AM, Andreas Gruenbacher
<andreas.gruenbacher@gmail.com> wrote:
> Changes nfs to support the "system.richacl" xattr instead of "system.nfs4_acl".
>

NACK.

You may declare a userspace syscall ABI that is more than 10 years old
to be deprecated, but you are not allowed to remove it.

Furthermore, your entire premise of using the mode bits and the acl at
the same time is flawed; you are at best trying to set up a private
protocol to pass your mask info. According to RFC7530, Section
6.4.1.3, if you try to send the mode bits and ACL in the same SETATTR,
then the result should be to apply the mode first, then override all
the lower mode bits (i.e. everything except the suid, sgid and ) with
the ACL...

Trond
