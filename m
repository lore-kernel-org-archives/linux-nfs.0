Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43511 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102AbcCKOBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 09:01:41 -0500
Date: Fri, 11 Mar 2016 06:01:34 -0800
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
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
Message-ID: <20160311140134.GA14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 29, 2016 at 09:17:05AM +0100, Andreas Gruenbacher wrote:
> Al,
> 
> could you please make sure you are happy with the current version of the
> richacl patch queue for the next merge window?

I'm still not happy.

For one I still see no reason to merge this broken ACL model at all.
It provides our actualy Linux users no benefit at all, while breaking
a lot of assumptions, especially by adding allow and deny ACE at the
same sime.

It also doesn't help with the issue that the main thing it's trying
to be compatible with (Windows) actually uses a fundamentally different
identifier to apply the ACLs to - as long as you're still limited
to users and groups and not guids we'll still have that mapping problem
anyway.

But besides that fundamental question on the purpose of it I also
don't think the code is suitable, more in the individual patches.
