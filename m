Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:40156 "EHLO namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbbJFJtl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Oct 2015 05:49:41 -0400
Date: Tue, 6 Oct 2015 20:49:04 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
To: Christoph Hellwig <hch@infradead.org>
cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v8 00/41] Richacls
In-Reply-To: <20151004062313.GA20212@infradead.org>
Message-ID: <alpine.LRH.2.20.1510062047220.2329@namei.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com> <20151004062313.GA20212@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 3 Oct 2015, Christoph Hellwig wrote:

> On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
> > Hello,
> > 
> > here's another update of the richacl patch queue.  At this stage, I would
> > like to ask for final feedback so that the core and ext4 code (patches
> > 1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code should
> > then go through the respective maintainer trees.
> 
> Now way in this form even if everyone agrees we should have these
> bastard ACLs.  I certainly disagree.
> 

Where is the rationale for them?

This url doesn't work: http://acl.bestbits.at/richacl/





-- 
James Morris
<jmorris@namei.org>

