Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37034 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaD1JEC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 05:04:02 -0400
Date: Mon, 28 Apr 2014 02:03:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 00/22]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20140428090356.GA20147@infradead.org>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20140428043909.GA26778@infradead.org>
 <87wqeaatj3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87wqeaatj3.fsf@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 28, 2014 at 11:24:08AM +0530, Aneesh Kumar K.V wrote:
> We already do that with richacl. Richacl already have most of the
> details implemented in common code. Comparing to recent posix acl
> changes we could still simplify chmod and xattr bits. I will do that
> in the next update. 

There's still tons of duplication.  There should be no code in the
filesystem except for a few callouts for the inode init and chmod path,
and the attr set/get should also be mostly in a library.  If you need
to add more than 20 lines to the filesystem you did something wrong.

> 
> >  - common data structure with Posix ACLs
> >
> 
> Can you explain this ?. Why do we want to do that ? 

One acl structure implementing the Posix and NFSv4 acls and instead
of a big pile of duplicate infrastructure.

