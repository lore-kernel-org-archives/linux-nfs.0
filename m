Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:51235 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754515AbcCOHR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 03:17:56 -0400
Date: Tue, 15 Mar 2016 00:17:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
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
Subject: Re: [PATCH v18 21/22] ext4: Add richacl support
Message-ID: <20160315071707.GF19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-22-git-send-email-agruenba@redhat.com>
 <20160311142719.GG14808@infradead.org>
 <CAHc6FU4TVKKYr-apCNTuR3aWAHpv7wZJ7ixePfy0Qt2VA49TZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU4TVKKYr-apCNTuR3aWAHpv7wZJ7ixePfy0Qt2VA49TZQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 14, 2016 at 12:08:31AM +0100, Andreas Gruenbacher wrote:
> The xattr representation is the same on disk and at the xattr syscall
> layer, and so richacl_from_xattr is used for converting into the
> in-memory representation in both cases. The error codes are not the
> same when a user supplies an invalid value via setxattr or NFS and
> when an invalid xattr is read from disk though. I'll add a parameter
> to richacl_from_xattr to make this more explicit.

Better add a wrapper instead of a parameter.

> 
> >> +static int
> >> +__ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
> >> +{
> >> +     const int name_index = EXT4_XATTR_INDEX_RICHACL;
> >> +     umode_t mode = inode->i_mode;
> >> +     int retval, size;
> >> +     void *value;
> >> +
> >> +     if (richacl_equiv_mode(acl, &mode) == 0) {
> >> +             inode->i_ctime = ext4_current_time(inode);
> >> +             inode->i_mode = mode;
> >> +             ext4_mark_inode_dirty(handle, inode);
> >> +             return __ext4_remove_richacl(handle, inode);
> >> +     }
> >
> > Should this check for a NULL acl instead of special casing that
> > in ext4_set_richacl?
> 
> I'm not sure I understand what you mean. When the

ext4_set_richacl checks for a NULL acl pointer and then calls into
__ext4_remove_richacl.  I'd rather have that special casing in one
place.
