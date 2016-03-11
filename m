Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49695 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067AbcCKOJu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 09:09:50 -0500
Date: Fri, 11 Mar 2016 06:09:47 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 09/22] richacl: Permission check algorithm
Message-ID: <20160311140947.GD14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-10-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456733847-17982-10-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  fs/Makefile             |   2 +-
>  fs/richacl_inode.c      | 149 ++++++++++++++++++++++++++++++++++++++++++++++++

What's the point of a tiny separate file here?  All richacls files
together are still small, and it would be much preferably to have all
that code together.
