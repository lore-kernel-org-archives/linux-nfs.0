Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:34664 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbbJESpm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 14:45:42 -0400
Received: by lbbwt4 with SMTP id wt4so25589380lbb.1
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 11:45:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151004062313.GA20212@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<20151004062313.GA20212@infradead.org>
Date: Mon, 5 Oct 2015 20:45:40 +0200
Message-ID: <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 4, 2015 at 8:23 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
>> Hello,
>>
>> here's another update of the richacl patch queue.  At this stage, I would
>> like to ask for final feedback so that the core and ext4 code (patches
>> 1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code should
>> then go through the respective maintainer trees.
>
> Now way in this form even if everyone agrees we should have these
> bastard ACLs.  I certainly disagree.

Well, thanks for having a look at the patches.

> Ayway, back to the VFS <-> FS interface.  You still require tons of
> boilderplate code in the filesystem which isn't required and we got rid
> of for Posix ACLs.  The filesystem should not look at the userspace
> xattr format, please follow a model similar to ->get_acl and ->set_acl
> for Posix ACLs.

I will repost a version that has this cleaned up.

> After that the wire up should be so trivial that you can wire up btrfs,
> xfs and f2fs as well, which is important to make the feature mergeable.

Why would the patch queue become more mergeable by having support for
more filesystems in it? The filesystem specific code really isn't all
that interesting.

> And honestly I tink adding even more overload to xattrs is a really bad
> idea and after 10 years of experience with that junk we really need to
> learn and make new overloads proper system calls.

Thanks,
Andreas
