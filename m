Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:49510 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755032AbcCOHLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 03:11:06 -0400
Date: Tue, 15 Mar 2016 00:10:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 19/22] richacl: Add richacl xattr handler
Message-ID: <20160315071014.GB19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-20-git-send-email-agruenba@redhat.com>
 <20160311141735.GF14808@infradead.org>
 <20160311141905.GC13178@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160311141905.GC13178@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 09:19:05AM -0500, J. Bruce Fields wrote:
> On Fri, Mar 11, 2016 at 06:17:35AM -0800, Christoph Hellwig wrote:
> > On Mon, Feb 29, 2016 at 09:17:24AM +0100, Andreas Gruenbacher wrote:
> > > Add richacl xattr handler implementing the xattr operations based on the
> > > get_richacl and set_richacl inode operations.
> > 
> > Given all the issues with Posix ACLs and selinux attributes these really
> > should be proper syscalls instead of abusing the xattr interface.
> 
> What are those problems exactly?

That people get confused between the attr used by the xattr syscall
interface and the attr used to store things on disk or the protocol.
This has happened every time we have non-native support, e.g. XFS, NFS,
CIFS, ntfs, etc.  And it's only going to become worse.
