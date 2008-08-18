From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_file_flush() question
Date: Mon, 18 Aug 2008 12:53:11 -0400
Message-ID: <1219078391.7192.4.camel@localhost>
References: <20080817002342.GA17223@yahoo-inc.com>
	 <1218992641.7999.2.camel@localhost>
	 <309543F5-E522-44CC-B114-C9652328FE0F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44401 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbYHRQxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2008 12:53:17 -0400
In-Reply-To: <309543F5-E522-44CC-B114-C9652328FE0F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-08-18 at 12:04 -0400, Chuck Lever wrote:
> Does the Linux NFS client optimize away the GETATTR when it has sent  
> only a single WRITE and the server has returned post-op attributes?   
> Using a large wsize with a modern server implementation might make  
> this a fairly common scenario.

Yes: please see the code. We use a standard nfs_revalidate_inode() which
will be optimised away if the inode metadata is known to be up to date.

Trond

