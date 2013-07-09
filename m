Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396Ab3GIT3M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 15:29:12 -0400
Date: Tue, 9 Jul 2013 15:29:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, David Howells <dhowells@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [PATCH 08/12] locks: break delegations on unlink
Message-ID: <20130709192908.GG32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-9-git-send-email-bfields@redhat.com>
 <20130709090506.71c96841@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709090506.71c96841@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 09:05:06AM -0400, Jeff Layton wrote:
> We probably also ought to eyeball some of these other cases where you
> passing in NULL as the deleg_inode too. It's probably reasonable in
> most cases -- exporting a filesystem that you also mount using ecryptfs
> seems silly, but you never know...

The cases in this patch:

	- devtmpfs, mqueue: not exportable

	- cachefiles, ecryptfs: probably nothing prevents exporting the
	  underlying filesystem, but it sounds nuts.  If somebody
	  actually runs into this case, we'll error out--the kernel
	  won't crash, the delegation won't be violated--and they can
	  come to us and try to make the case why this is a problem.

	- nfsd: handles delegation breaks in its own way (by returning a
	  DELAY error to the client and leaving it to the client to
	  retry).

--b.
