Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:45398
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825Ab1IUPCo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 11:02:44 -0400
Date: Wed, 21 Sep 2011 11:02:41 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/6] leases: break read leases on unlink
Message-ID: <20110921150241.GA11452@infradead.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316617097-21384-4-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 21, 2011 at 10:58:14AM -0400, J. Bruce Fields wrote:
> A read lease is used by NFSv4 as a guarantee that a client can perform
> local read opens without informing the server.
> 
> The open operation takes the last component of the pathname as an
> argument, thus is also a lookup operation, and giving the client the
> above guarantee means informing the client before we allow anything that
> would change the set of names pointing to the inode.

That seems like totally strange semantics.  A useful defintion of a
lase operation would mean it guarantees I/O can happen, and wouldn't
care about metadata operation.  That's the whole point in adding a
stateful open to nfs4, isn't it?

