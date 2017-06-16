Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36845 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753009AbdFPJGY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2017 05:06:24 -0400
Date: Fri, 16 Jun 2017 02:06:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: David Howells <dhowells@redhat.com>, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 07/27] VFS: Differentiate mount flags (MS_*) from
 internal superblock flags [ver #5]
Message-ID: <20170616090621.GA13775@infradead.org>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745338248.10897.17175227466711674034.stgit@warthog.procyon.org.uk>
 <20170615093927.GG31671@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170615093927.GG31671@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, this patch didn't seem to make it through to the list, probably
because it was too large.

It might be good to just introduce the internal flags field first,
populate it with the translated flags, then switch users over to
it, and last but not least remove the old flags field and the MS_*
values that were only used internally.

Also if would be good to sort this out in a separate series without
all the mount context stuff.
