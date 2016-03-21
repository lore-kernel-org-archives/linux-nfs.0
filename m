Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42878 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbcCUQJ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 12:09:27 -0400
Date: Mon, 21 Mar 2016 09:09:22 -0700
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
Message-ID: <20160321160922.GA18734@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-20-git-send-email-agruenba@redhat.com>
 <20160311141735.GF14808@infradead.org>
 <20160311141905.GC13178@fieldses.org>
 <20160315071014.GB19747@infradead.org>
 <20160315210526.GC3658@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160315210526.GC3658@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 05:05:26PM -0400, J. Bruce Fields wrote:
> > That people get confused between the attr used by the xattr syscall
> > interface and the attr used to store things on disk or the protocol.
> > This has happened every time we have non-native support, e.g. XFS, NFS,
> > CIFS, ntfs, etc.  And it's only going to become worse.
> 
> How has that confusion caused problems in practice?

We had all kinds of bugs in this area that were only slowly uncovered.
We also had all kind of privilegue escalations with (non-ACLs) xattrs
as people never grasped the way different free-form namespaces have
different permission checking.
