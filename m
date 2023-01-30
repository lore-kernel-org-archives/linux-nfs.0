Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59723C63797
	for <linux-nfs@archiver.kernel.org>; Mon, 30 Jan 2023 10:33:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236275AbjA3Kdv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 30 Jan 2023 05:33:51 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59614 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235321AbjA3Kdt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2023 05:33:49 -0500
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7CB429B;
        Mon, 30 Jan 2023 02:33:47 -0800 (PST)
Received: by verein.lst.de (Postfix, from userid 2407)
        id A6F2268D06; Mon, 30 Jan 2023 11:33:43 +0100 (CET)
Date:   Mon, 30 Jan 2023 11:33:43 +0100
From:   Christoph Hellwig <hch@lst.de>
To:     David Howells <dhowells@redhat.com>
Cc:     Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
        ceph-devel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        devel@lists.orangefs.org, io-uring@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 20/23] rxrpc: use bvec_set_page to initialize a bvec
Message-ID: <20230130103343.GA11663@lst.de>
References: <20230130092157.1759539-21-hch@lst.de> <20230130092157.1759539-1-hch@lst.de> <3347459.1675074683@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3347459.1675074683@warthog.procyon.org.uk>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jan 30, 2023 at 10:31:23AM +0000, David Howells wrote:
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > +		bvec_set_page(&bv, ZERO_PAGE(0), len, 0);
> 
> Maybe bvec_set_zero_page()?

Why?
