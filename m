Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36847 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932561AbcCKQLw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 11:11:52 -0500
Received: by mail-vk0-f46.google.com with SMTP id c3so139456933vkb.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Mar 2016 08:11:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160311140134.GA14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
	<20160311140134.GA14808@infradead.org>
Date: Fri, 11 Mar 2016 17:11:51 +0100
Message-ID: <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 3:01 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Feb 29, 2016 at 09:17:05AM +0100, Andreas Gruenbacher wrote:
>> Al,
>>
>> could you please make sure you are happy with the current version of the
>> richacl patch queue for the next merge window?
>
> I'm still not happy.
>
> For one I still see no reason to merge this broken ACL model at all.
> It provides our actualy Linux users no benefit at all,

This permission model is useful in mixed environments that involve
UNIX and Windows machines. Think of NAS boxes with Linux and Windows
clients, for example. It also fits the NFSv4 ACL model very well. If
you're not a user dealing with such environments, then the model
likely won't provide any benefits to *you*, and you're better off with
a less complicated permission model. That doesn't say anything about
other users, though.

> while breaking a lot of assumptions,

The model is designed specifically to be compliant with the POSIX
permission model. What assumptions are you talking about?

> especially by adding allow and deny ACE at the same time.

I remember from past discussions that a permission model like the
POSIX ACL model that doesn't have DENY ACEs would be more to your
liking. This argument is dead from the start though: NFSv4 ACLs
without DENY ACEs cannot represent basic file permissions like 0604
where the owning group has fewer permissions than others, for example
(see the richaclex(7) man page). We would end up with a permission
model that isn't even compatible with the traditional POSIX file
permission model, one which nobody else implements or cares about.

> It also doesn't help with the issue that the main thing it's trying
> to be compatible with (Windows) actually uses a fundamentally different
> identifier to apply the ACLs to - as long as you're still limited
> to users and groups and not guids we'll still have that mapping problem
> anyway.

Samba has been dealing with mapping between SIDs and UIDs/GIDs for a
long time, and it's working acceptably well.

We could store SIDs in ACEs, but that wouldn't make the actual
problems go away: Files on Linux have an owner and an owning group
which are identitifed by UID/GID, whereas a file is owned by a SID
which can be either a user or a group in a SID world. Also, processes
on Linux have an owner and a list of groups which are identified by
UID/GID, so any SIDs stored in filesystems would never match a
process, anyway.

(NFSv4 refers to users and groups as opposed to SIDs, and so it
doesn't have this problem.)

Thanks,
Andreas
