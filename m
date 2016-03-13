Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:36039 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370AbcCMXIc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Mar 2016 19:08:32 -0400
Received: by mail-vk0-f41.google.com with SMTP id c3so189553133vkb.3
        for <linux-nfs@vger.kernel.org>; Sun, 13 Mar 2016 16:08:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160311142719.GG14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
	<1456733847-17982-22-git-send-email-agruenba@redhat.com>
	<20160311142719.GG14808@infradead.org>
Date: Mon, 14 Mar 2016 00:08:31 +0100
Message-ID: <CAHc6FU4TVKKYr-apCNTuR3aWAHpv7wZJ7ixePfy0Qt2VA49TZQ@mail.gmail.com>
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
>
> Also while we're at it, the mode argument is ignore and the function
> always uses inode->i_mode instead.
>
>> +ext4_get_richacl(struct inode *inode)
>> +{
>> +     const int name_index = EXT4_XATTR_INDEX_RICHACL;
>> +     void *value = NULL;
>> +     struct richacl *acl = NULL;
>> +     int retval;
>> +
>> +     retval = ext4_xattr_get(inode, name_index, "", NULL, 0);
>> +     if (retval > 0) {
>> +             value = kmalloc(retval, GFP_NOFS);
>> +             if (!value)
>> +                     return ERR_PTR(-ENOMEM);
>> +             retval = ext4_xattr_get(inode, name_index, "", value, retval);
>> +     }
>> +     if (retval > 0) {
>> +             acl = richacl_from_xattr(&init_user_ns, value, retval);
>> +             if (acl == ERR_PTR(-EINVAL))
>> +                     acl = ERR_PTR(-EIO);
>
> Shouldn't richacl_from_xattr return the error pointer that ->get_richacl
> callers expect?

The xattr representation is the same on disk and at the xattr syscall
layer, and so richacl_from_xattr is used for converting into the
in-memory representation in both cases. The error codes are not the
same when a user supplies an invalid value via setxattr or NFS and
when an invalid xattr is read from disk though. I'll add a parameter
to richacl_from_xattr to make this more explicit.

>> +static int
>> +__ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
>> +{
>> +     const int name_index = EXT4_XATTR_INDEX_RICHACL;
>> +     umode_t mode = inode->i_mode;
>> +     int retval, size;
>> +     void *value;
>> +
>> +     if (richacl_equiv_mode(acl, &mode) == 0) {
>> +             inode->i_ctime = ext4_current_time(inode);
>> +             inode->i_mode = mode;
>> +             ext4_mark_inode_dirty(handle, inode);
>> +             return __ext4_remove_richacl(handle, inode);
>> +     }
>
> Should this check for a NULL acl instead of special casing that
> in ext4_set_richacl?

I'm not sure I understand what you mean. When the

>> +int
>> +ext4_init_richacl(handle_t *handle, struct inode *inode, struct inode *dir)
>> +{
>> +     struct richacl *acl = richacl_create(&inode->i_mode, dir);
>> +     int error;
>> +
>> +     error = PTR_ERR(acl);
>> +     if (IS_ERR(acl))
>> +             return error;
>
>         if (IS_ERR(acl))
>                 return PTR_ERR(acl);
>
>> +     if (acl) {
>> +             error = __ext4_set_richacl(handle, inode, acl);
>> +             richacl_put(acl);
>> +     }
>
> Shouldn't richacl_create return NULL if the ACL is equivalent to the
> mode bits instead of letting every filesystem figure that out on it's
> own?
>
