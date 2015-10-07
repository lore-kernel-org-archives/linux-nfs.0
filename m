Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36078 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbbJGPPk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 11:15:40 -0400
MIME-Version: 1.0
In-Reply-To: <CAHc6FU7TM5LDu_vVvDc3WPuzQN2mkGGp2AvCY+=qN0GvWuC=Ew@mail.gmail.com>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org> <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
 <5612C85C.2060407@gmail.com> <20151006094935.GA14144@infradead.org>
 <CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com>
 <CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca> <20151007075053.GA8660@infradead.org>
 <CAHc6FU7TM5LDu_vVvDc3WPuzQN2mkGGp2AvCY+=qN0GvWuC=Ew@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Wed, 7 Oct 2015 10:15:19 -0500
Message-ID: <CAH2r5mt18-CQLCMz0RHnK_sXW5oOFpf2kMVeWJRvrD3Vw2MWLw@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andreas Dilger <adilger@dilger.ca>,
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
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 7, 2015 at 8:38 AM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> On Wed, Oct 7, 2015 at 9:50 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> On Tue, Oct 06, 2015 at 02:26:09PM -0600, Andreas Dilger wrote:
>>> And any disk filesystems that have their own non-POSIX ACLs, such as HFS, NTFS, ZFS would presumably also need to map the in-kernel Richacl format to their on-disk format.
>>
>> No, we did this mistake with Posix ACLs, and we're not going to repeat
>> it here.  Filesystems with their own slightly different ACLs must not
>> reuse the interface.
>
> Well, things may not be quite as clearly delineated. We currently have
> code in nfsd for mapping between NFSv4 ACLs on the wire and POSIX ACLs
> on local file systems. This mapping is problematic because of the
> semantic differences between NFSv4 ACLs and POSIX ACLs (different sets
> of permissions, access and default acl vs. inheritance flags,
> different permission check algorithm). I wish we could have avoided
> that.
>
> Richacls are designed to support NFSv4 ACLs on top of POSIX systems.
> This means that they should obviously be supported by the NFSv4 server
> and client (see the patches) and by the common local filesystems.
>
> ACLs on NTFS and ZFS mostly fit into the same model. The big remaining
> difference there is how users and groups are identified: NTFS used
> SIDs (https://en.wikipedia.org/wiki/Security_Identifier); ZFS could be
> said to use a hybrid UID / GID / SID model. Exposing those ACLs as
> richacls would make sense if we can find a clean way of handling this
> aspect.

Samba (e.g. winbind service) has mapping libraries for mapping SIDs to
UIDs (CIFS ACLs already have the same issue of SID to UID mapping
which we handle with upcalls) and Samba has various pluggable ways to
handle UID mapping and is easily extensible.  Similarly NFSv4 ACLs,
although closely related to CIFS/NTFS ACLs have to be map usernames to
uids.

-- 
Thanks,

Steve
