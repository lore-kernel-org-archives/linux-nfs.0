Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36259 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbbKDCnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 21:43:33 -0500
Received: by lbjm5 with SMTP id m5so6037250lbj.3
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 18:43:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHc6FU46EuDQ0S9TPYuLosHvppsqcqOF_oxxgTFHr+uXj59Drg@mail.gmail.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
	<1446563847-14005-22-git-send-email-agruenba@redhat.com>
	<06282344-726E-49AD-936B-7BFF8F43B967@dilger.ca>
	<CAHc6FU46EuDQ0S9TPYuLosHvppsqcqOF_oxxgTFHr+uXj59Drg@mail.gmail.com>
Date: Wed, 4 Nov 2015 03:43:31 +0100
Message-ID: <CAHc6FU4=aNhir7UJjr=Xh28aWB7sZ0xhaawpmHxeB33RzaMHug@mail.gmail.com>
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

On Wed, Nov 4, 2015 at 3:28 AM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> It's the commit message that's misleading here, I'll fix it.

Commit message changed to:

    This feature flag selects richacl instead of POSIX ACL support on the
    filesystem.  When this feature is off, the "acl" and "noacl" mount options
    control whether POSIX ACLs are enabled.  When it is on, richacls are
    automatically enabled and using the "noacl" mount option leads to an error.

Thanks,
Andreas
