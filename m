Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38038 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbdFPPuC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2017 11:50:02 -0400
Date: Fri, 16 Jun 2017 08:49:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 07/27] VFS: Differentiate mount flags (MS_*) from
 internal superblock flags [ver #5]
Message-ID: <20170616154959.GA27209@infradead.org>
References: <20170616090621.GA13775@infradead.org>
 <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745338248.10897.17175227466711674034.stgit@warthog.procyon.org.uk>
 <20170615093927.GG31671@ZenIV.linux.org.uk>
 <9141.1497624810@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9141.1497624810@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 16, 2017 at 03:53:30PM +0100, David Howells wrote:
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > It might be good to just introduce the internal flags field first,
> 
> Internal flags field?  Did you mean Al's suggested sb_readonly() wrapper?

(1) Add a new SB field that is like s_flags but for the new flags,
(2) switch users over to the new field
(3) remove s_flags
