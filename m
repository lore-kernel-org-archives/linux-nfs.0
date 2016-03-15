Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:51486 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934103AbcCOHTq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 03:19:46 -0400
Date: Tue, 15 Mar 2016 00:18:54 -0700
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
Message-ID: <20160315071854.GG19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-22-git-send-email-agruenba@redhat.com>
 <20160311142719.GG14808@infradead.org>
 <CAHc6FU64SzTN23LMzGcPex=jRz_Euwb_CHrW=kX+A5sn8=SFSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU64SzTN23LMzGcPex=jRz_Euwb_CHrW=kX+A5sn8=SFSg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 14, 2016 at 02:02:33PM +0100, Andreas Gruenbacher wrote:
> On Fri, Mar 11, 2016 at 3:27 PM, Christoph Hellwig <hch@infradead.org> wrote:
> >> +static inline int
> >> +ext4_acl_chmod(struct inode *inode, umode_t mode)
> >> +{
> >> +     if (IS_RICHACL(inode))
> >> +             return richacl_chmod(inode, inode->i_mode);
> >> +     return posix_acl_chmod(inode, inode->i_mode);
> >> +}
> >
> > Thi isn't ext4-specific and potentially duplicated in every caller.
> > Please provide this as a common helper.
> 
> This can go in neither fs.h nor posix_acl.h nor richacl.h unless we
> turn it into a macro, and I don't think we want to add a new header
> file for such extreme trivia.

I'd expect us to grow a few more of thos helper if we get the sharing
right (either a real common base object, or wrappers for anything
dealing with the acl pointers in the inode), so a new linux/acl.h
should be fine.
