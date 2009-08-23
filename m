From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Handle a zero-length auth flavor list
Date: Sun, 23 Aug 2009 15:41:50 -0400
Message-ID: <1251056510.16283.6.camel@heimdal.trondhjem.org>
References: <20090821215006.28834.73753.stgit@matisse.1015granger.net>
	 <1250962458.8143.24.camel@heimdal.trondhjem.org>
	 <50C4E02A-ADB5-454B-8B13-751C8E737A9F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:43647 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933939AbZHWTlw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Aug 2009 15:41:52 -0400
In-Reply-To: <50C4E02A-ADB5-454B-8B13-751C8E737A9F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-08-23 at 14:57 -0400, Chuck Lever wrote:
> If this was an issue in 2.6.31-rc, the patch description should  
> probably read "pre-2.6.31" not "pre-2.6.32".

As far as I know, Fengguang was testing with a linux-next kernel which
contains your auth negotiation code. None of this is scheduled to be
merged into the 2.6.31-rc series.

Cheers
  Trond

