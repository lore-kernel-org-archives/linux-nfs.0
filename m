Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38759 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493Ab1IHJcb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 05:32:31 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 8 Sep 2011 03:32:30 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 10/26] vfs: Make the inode passed to inode_change_ok non-const
In-Reply-To: <20110907204321.GF8074@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110907204321.GF8074@fieldses.org>
Date: Thu, 08 Sep 2011 15:02:15 +0530
Message-ID: <87fwk75qhs.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 7 Sep 2011 16:43:22 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Sep 05, 2011 at 10:55:32PM +0530, Aneesh Kumar K.V wrote:
> > From: Andreas Gruenbacher <agruen@kernel.org>
> > 
> > We will need to call iop->permission and iop->get_acl from
> > inode_change_ok() for additional permission checks, and both take a
> > non-const inode.
> 
> OK, the essential difference being that richacls have a say in whether
> we can change attributes or not, which posix acls (for example) don't?
> 

yes, next patch explain the details of the check

-aneesh

