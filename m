Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:50780 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933405AbcCOHP3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 03:15:29 -0400
Date: Tue, 15 Mar 2016 00:14:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve French <smfrench@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
Message-ID: <20160315071439.GE19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org>
 <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
 <CAH2r5mv3OTmPOQBV7xc-uZmB0gWxykXOCEVOcybx3tbHiViTZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5mv3OTmPOQBV7xc-uZmB0gWxykXOCEVOcybx3tbHiViTZg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 02:05:16PM -0600, Steve French wrote:
> A loosely related question is what can be done for tools around existing
> interfaces for ACLs.  I recently found out NTFS-3g has this xattr:
> 
>     static const char nf_ns_xattr_ntfs_acl[] = "system.ntfs_acl";
> 
> which allows you to query system.ntfs_acl xattr to get their full ACL

Bah.  Filesystems really have no business exposing random system xattrs,
and we really need to add a filter to fs/xattr.c to not expose
arbitrary attrs ouside the user.* prefix.
