Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55094 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbaG0Tup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 15:50:45 -0400
Date: Sun, 27 Jul 2014 12:50:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Andrey Utkin <andrey.krieger.utkin@gmail.com>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org, Russell King <linux@arm.linux.org.uk>
Subject: Re: [PATCH] nfs3_list_one_acl(): check get_acl() result with
 IS_ERR_OR_NULL
Message-ID: <20140727195041.GA11575@infradead.org>
References: <1406375881-18837-1-git-send-email-andrey.krieger.utkin@gmail.com>
 <20140727131917.GA32153@infradead.org>
 <CAHQdGtRzDzpOuwZYWaBake-bH0z0eyMd2g-RTVwO0d2f0Zmsow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRzDzpOuwZYWaBake-bH0z0eyMd2g-RTVwO0d2f0Zmsow@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 27, 2014 at 11:13:50AM -0400, Trond Myklebust wrote:
> Why are we not passing the error code back to the caller here in the
> case where we have one? One of the main purposes of returning an error
> in get_acl() is to ensure that we pass -EOPNOTSUPP if the operation
> fails due to lack of server support.

Do we really want to return EOPNOTSUPP from listxattr?  Seems like
simply not listing anything if the server doesn't support ACLs would
be the usual behaviour.  E.g. on local filesystems we'll also just get
back an empty list of xattrs if ACLs aren't supported and not other
attribute is set.

