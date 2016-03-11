Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:34535 "EHLO
	mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932589AbcCKQYq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 11:24:46 -0500
Received: by mail-vk0-f53.google.com with SMTP id e185so139943936vkb.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Mar 2016 08:24:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160311140746.GC14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
	<1456733847-17982-12-git-send-email-agruenba@redhat.com>
	<20160311140746.GC14808@infradead.org>
Date: Fri, 11 Mar 2016 17:24:45 +0100
Message-ID: <CAHc6FU7hSDBa51mJZZZ=q3agzWXk=DZicnyuPriKHnC2Nxr8rw@mail.gmail.com>
Subject: Re: [PATCH v18 11/22] vfs: Cache base_acl objects in inodes
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
        Anna Schumaker <anna.schumaker@netapp.com>, jaegeuk@kernel.org,
        chao2.yu@samsung.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 3:07 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Feb 29, 2016 at 09:17:16AM +0100, Andreas Gruenbacher wrote:
>> POSIX ACLs and richacls are both objects allocated by kmalloc() with a
>> reference count which are freed by kfree_rcu().  An inode can either
>> cache an access and a default POSIX ACL, or a richacl (richacls do not
>> have default acls).  To allow an inode to cache either of the two kinds
>> of acls, introduce a new base_acl type and convert i_acl and
>> i_default_acl to that type. In most cases, the vfs then doesn't care which
>> kind of acl an inode caches (if any).
>
> This base_acl object is pointless.  I've asked in the past to have
> a proper container for the ACLs in common code, but a union
> of a refcount and a rcu head doesn't really fit that category.

POSIX ACLs and RichACLs are different objects, with different members
and different algorithms operating on them. The only commonality is
that they are both kmalloc()ed, reference counted objects, and when an
inode is destroyed, both kinds of ACLs can be put in the same way,
avoiding an unnecessary if. What kind of common-code container beyond
that are you still dreaming about?

Thanks,
Andreas
