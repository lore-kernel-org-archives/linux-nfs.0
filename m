Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36401 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbJGNiu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 09:38:50 -0400
Received: by lbcao8 with SMTP id ao8so11535793lbc.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 06:38:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151007075053.GA8660@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<20151004062313.GA20212@infradead.org>
	<CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
	<5612C85C.2060407@gmail.com>
	<20151006094935.GA14144@infradead.org>
	<CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com>
	<CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca>
	<20151007075053.GA8660@infradead.org>
Date: Wed, 7 Oct 2015 15:38:48 +0200
Message-ID: <CAHc6FU7TM5LDu_vVvDc3WPuzQN2mkGGp2AvCY+=qN0GvWuC=Ew@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andreas Dilger <adilger@dilger.ca>,
        Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 7, 2015 at 9:50 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Oct 06, 2015 at 02:26:09PM -0600, Andreas Dilger wrote:
>> And any disk filesystems that have their own non-POSIX ACLs, such as HFS, NTFS, ZFS would presumably also need to map the in-kernel Richacl format to their on-disk format.
>
> No, we did this mistake with Posix ACLs, and we're not going to repeat
> it here.  Filesystems with their own slightly different ACLs must not
> reuse the interface.

Well, things may not be quite as clearly delineated. We currently have
code in nfsd for mapping between NFSv4 ACLs on the wire and POSIX ACLs
on local file systems. This mapping is problematic because of the
semantic differences between NFSv4 ACLs and POSIX ACLs (different sets
of permissions, access and default acl vs. inheritance flags,
different permission check algorithm). I wish we could have avoided
that.

Richacls are designed to support NFSv4 ACLs on top of POSIX systems.
This means that they should obviously be supported by the NFSv4 server
and client (see the patches) and by the common local filesystems.

ACLs on NTFS and ZFS mostly fit into the same model. The big remaining
difference there is how users and groups are identified: NTFS used
SIDs (https://en.wikipedia.org/wiki/Security_Identifier); ZFS could be
said to use a hybrid UID / GID / SID model. Exposing those ACLs as
richacls would make sense if we can find a clean way of handling this
aspect.

HFS ACLs have sufficiently different semantics (the user.group tuples)
that representing them as richacls wouldn't make sense.

Thanks,
Andreas
