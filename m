Return-Path: <SRS0=+Eh1=BU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 659EBC433E1
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Aug 2020 16:40:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 34D02207DE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Aug 2020 16:40:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727771AbgHJQks (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Aug 2020 12:40:48 -0400
Received: from verein.lst.de ([213.95.11.211]:37060 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726942AbgHJQks (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Aug 2020 12:40:48 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 5E9D468AFE; Mon, 10 Aug 2020 18:40:44 +0200 (CEST)
Date:   Mon, 10 Aug 2020 18:40:44 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     David Howells <dhowells@redhat.com>
Cc:     torvalds@linux-foundation.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Matthew Wilcox <willy@infradead.org>,
        Christoph Hellwig <hch@lst.de>,
        Jeff Layton <jlayton@redhat.com>,
        Dave Wysochanski <dwysocha@redhat.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        linux-cachefs@redhat.com, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        ceph-devel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [GIT PULL] fscache rewrite -- please drop for now
Message-ID: <20200810164044.GA31753@lst.de>
References: <1851200.1596472222@warthog.procyon.org.uk> <447452.1596109876@warthog.procyon.org.uk> <667820.1597072619@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <667820.1597072619@warthog.procyon.org.uk>
User-Agent: Mutt/1.5.17 (2007-11-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Aug 10, 2020 at 04:16:59PM +0100, David Howells wrote:
> Hi Linus,
> 
> Can you drop the fscache rewrite pull for now.  We've seem an issue in NFS
> integration and need to rework the read helper a bit.  I made an assumption
> that fscache will always be able to request that the netfs perform a read of a
> certain minimum size - but with NFS you can break that by setting rsize too
> small.
> 
> We need to make the read helper able to make multiple netfs reads.  This can
> help ceph too.

FYI, a giant rewrite dropping support for existing consumer is always
rather awkward.  Is there any way you could pre-stage some infrastructure
changes, and then do a temporary fscache2, which could then be renamed
back to fscache once everyone switched over?
