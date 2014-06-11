Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44982 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754908AbaFKQWj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2014 12:22:39 -0400
Date: Wed, 11 Jun 2014 09:22:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Philippe Troin <phil@fifi.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: Phantom ACL-related xattrs on 3.14.4 NFS client
Message-ID: <20140611162238.GA28340@infradead.org>
References: <1402082953.28220.7.camel@ceramic.home.fifi.org>
 <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
 <20140607140414.GA26534@infradead.org>
 <1402195701.12743.18.camel@ceramic.home.fifi.org>
 <1402435203.24047.9.camel@ceramic.home.fifi.org>
 <20140611072402.GA2683@infradead.org>
 <1402503318.27314.12.camel@niobium.home.fifi.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1402503318.27314.12.camel@niobium.home.fifi.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 11, 2014 at 09:15:18AM -0700, Philippe Troin wrote:
> So, the only regression remaining between 3.13.11 and 3.14.6 + your
> patch is the one where listxattr(2) and friends do not NUL-terminate the
> xattr names they return.  This is detailed in
> <1402435203.24047.9.camel@ceramic.home.fifi.org> I sent yesterday.

Oh, that's a bug in my patch.  The following incremental patch should
fix it:

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index e083827..8f854dd 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -262,6 +262,7 @@ nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
 	posix_acl_release(acl);
 
 	*result += strlen(name);
+	*result += 1;
 	if (!size)
 		return 0;
 	if (*result > size)
