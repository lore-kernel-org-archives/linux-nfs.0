Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35758 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbbI1XmG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 19:42:06 -0400
Received: by laer8 with SMTP id r8so48904622lae.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2015 16:42:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150928152806.GC1358@fieldses.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<1443391772-10171-10-git-send-email-agruenba@redhat.com>
	<20150928152806.GC1358@fieldses.org>
Date: Tue, 29 Sep 2015 01:42:03 +0200
Message-ID: <CAHc6FU4NXra9okLekNNCx3mQa4TrJhZ8eqCWQ7pBgarHRphg6Q@mail.gmail.com>
Subject: Re: [PATCH v8 09/41] richacl: Update the file masks in chmod()
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-28 17:28 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Sep 28, 2015 at 12:09:00AM +0200, Andreas Gruenbacher wrote:
>> +         (acl->a_flags & (RICHACL_WRITE_THROUGH | RICHACL_MASKED)))
>
> I think you meant to require both of those bits to be set.

Yes, indeed.

Thanks,
Andreas
