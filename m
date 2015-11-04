Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33051 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755675AbbKDC2G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 21:28:06 -0500
Received: by lbbkw15 with SMTP id kw15so46743lbb.0
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 18:28:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <06282344-726E-49AD-936B-7BFF8F43B967@dilger.ca>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
	<1446563847-14005-22-git-send-email-agruenba@redhat.com>
	<06282344-726E-49AD-936B-7BFF8F43B967@dilger.ca>
Date: Wed, 4 Nov 2015 03:28:03 +0100
Message-ID: <CAHc6FU46EuDQ0S9TPYuLosHvppsqcqOF_oxxgTFHr+uXj59Drg@mail.gmail.com>
Subject: Re: [PATCH v13 21/51] ext4: Add richacl feature flag
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andreas,

On Wed, Nov 4, 2015 at 3:18 AM, Andreas Dilger <adilger@dilger.ca> wrote:
> This patch confuses me.  I thought the whole point of INCOMPAT_RICHACL
> was that the filesystem should never, ever be mounted without ACL support
> because the ACLs will get confused without it.  In that case, it doesn't
> make sense to have a mount option that _has_ to be specified to mount the
> filesystem, and returns an error when trying to disable it.
>
> It makes more sense to just enable "acl" by default if INCOMPAT_RICHACL
> is set in the superblock and not need the mount option at all.

It's the commit message that's misleading here, I'll fix it. On
richacl filesystems, the acl mount option is always on. It's only on
POSIX ACL filesystems that the mount option can be used to turn POSIX
ACLs off (which arguably wasn't such a good idea, but there we have
it).

Thanks,
Andreas
