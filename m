Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:35767 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbcCNNCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2016 09:02:34 -0400
Received: by mail-vk0-f45.google.com with SMTP id e6so206978448vkh.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2016 06:02:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160311142719.GG14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
	<1456733847-17982-22-git-send-email-agruenba@redhat.com>
	<20160311142719.GG14808@infradead.org>
Date: Mon, 14 Mar 2016 14:02:33 +0100
Message-ID: <CAHc6FU64SzTN23LMzGcPex=jRz_Euwb_CHrW=kX+A5sn8=SFSg@mail.gmail.com>
Subject: Re: [PATCH v18 21/22] ext4: Add richacl support
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
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

On Fri, Mar 11, 2016 at 3:27 PM, Christoph Hellwig <hch@infradead.org> wrote:
>> +static inline int
>> +ext4_acl_chmod(struct inode *inode, umode_t mode)
>> +{
>> +     if (IS_RICHACL(inode))
>> +             return richacl_chmod(inode, inode->i_mode);
>> +     return posix_acl_chmod(inode, inode->i_mode);
>> +}
>
> Thi isn't ext4-specific and potentially duplicated in every caller.
> Please provide this as a common helper.

This can go in neither fs.h nor posix_acl.h nor richacl.h unless we
turn it into a macro, and I don't think we want to add a new header
file for such extreme trivia.

> Also while we're at it, the mode argument is ignore and the function
> always uses inode->i_mode instead.

Right, thanks.

Andreas
