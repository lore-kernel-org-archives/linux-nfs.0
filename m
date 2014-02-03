Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35132 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaBCH4V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 02:56:21 -0500
Date: Sun, 2 Feb 2014 23:56:13 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Noah Massey <noah.massey@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfs: fix setting of ACLs on file creation.
Message-ID: <20140203075613.GA806@infradead.org>
References: <1391135472-9639-1-git-send-email-Noah.Massey@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1391135472-9639-1-git-send-email-Noah.Massey@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 09:31:12PM -0500, Noah Massey wrote:
> From: Noah Massey <noah.massey@gmail.com>
> 
> nfs3_get_acl() tries to skip posix equivalent ACLs, but misinterprets
> the return value of posix_acl_equiv_mode(). Fix it.
> 
> This is a regression introduced by
> "nfs: use generic posix ACL infrastructure for v3 Posix ACLs"

Thanks for catching this Noah!

Reviewed-by: Christoph Hellwig <hch@lst.de>
