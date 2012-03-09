Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48869 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756821Ab2CIWVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:21:17 -0500
Date: Fri, 9 Mar 2012 17:21:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: take i_mutex on renamed file
Message-ID: <20120309222114.GA22423@fieldses.org>
References: <20120305223847.GA16444@fieldses.org>
 <20120305224334.GB16444@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120305224334.GB16444@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 05, 2012 at 05:43:34PM -0500, J. Bruce Fields wrote:
> Al, do you see any reason this won't work?
> 
> After this, all I need to make nfsd happy is a patch to locks.c to
> implement delegations, and then a few one-liners to add break_deleg
> calls in the right operations.  So this is the one non-trivial change I
> have to core vfs code.
> 
> All of those patches are also ready, and I'd like to merge them for 3.4.

By the way, the following is the rest of the series.

(Compared to the last posting the deleg-breaking interface is
simplified.)

--b.
