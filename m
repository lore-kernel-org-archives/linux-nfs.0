Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56559 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab1CTMyf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Mar 2011 08:54:35 -0400
Date: Sun, 20 Mar 2011 12:54:30 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Dan Carpenter <error27@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfs: lock() vs unlock() typo
Message-ID: <20110320125430.GO22723@ZenIV.linux.org.uk>
References: <20110320112207.GM2008@bicker>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110320112207.GM2008@bicker>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Mar 20, 2011 at 02:22:07PM +0300, Dan Carpenter wrote:
> These should be spin_unlock() instead of spin_lock().  It's a typo.

Gyah...  Applied, thanks.
