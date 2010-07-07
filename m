Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757376Ab0GGQt2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 12:49:28 -0400
Date: Wed, 7 Jul 2010 12:49:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/10] Security: Add Hook to test if the particular
 xattr is part of a MAC model.
Message-ID: <20100707164919.GB28815@fieldses.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
 <1278513086-23964-3-git-send-email-dpquigl@tycho.nsa.gov>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1278513086-23964-3-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 07, 2010 at 10:31:18AM -0400, David P. Quigley wrote:
> There are areas in the Labeled NFS code where where we need to test if the
> attribute being requested exhibits the semantics of a MAC model.

I have no idea what that means....

> + * @ismaclabel:
> + * 	Check if the extended attribute specified by @name represents a MAC label.

Is this what you mean to say?

--b.
