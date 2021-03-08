Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24CA4C433DB
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Mar 2021 23:22:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DBBA4652A4
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Mar 2021 23:21:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229971AbhCHXV2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Mar 2021 18:21:28 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59676 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229471AbhCHXUw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2021 18:20:52 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1FE8EC06174A;
        Mon,  8 Mar 2021 15:20:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=2C5j2UcjDYW9mYgwyHgqIe6Gz5l4DgveyBW595u9faQ=; b=u+am1ZJapiahZOpG2Rwq/AVvg0
        oMfCYqTuZ4G+EEFNf60psslnnYYQ0bbgF+NILXiFCOjwDyIgbjxuoiEcZQv00o0WYpJH1isO6VRiC
        xYhhvDFUoAUq9mIBi134gw3MfadH7JZ8AY9yEPnnUaxdK/iPAhg4iMyVH2wp4QF2zZ8pHolQggvnC
        xkstHI6NejffxlN2RUIbiVQHfFT1cY1WUrPkEUFw5zfKwYkey4uzhSAMgcQE82RxexMMQ0BxHPpoW
        X5J5LxbtGQdKzueTczFA09whN8xNZpVy9+J6I+M7eNGql2/XixHhZefyZteV2oaZFdcbjk91b7H/G
        FOm50ufw==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lJPAg-00GbJf-5O; Mon, 08 Mar 2021 23:20:22 +0000
Date:   Mon, 8 Mar 2021 23:20:18 +0000
From:   Matthew Wilcox <willy@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     David Howells <dhowells@redhat.com>,
        Amir Goldstein <amir73il@gmail.com>, linux-cachefs@redhat.com,
        Jeff Layton <jlayton@redhat.com>,
        David Wysochanski <dwysocha@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Dave Chinner <dchinner@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-afs@lists.infradead.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        CIFS <linux-cifs@vger.kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>,
        v9fs-developer@lists.sourceforge.net,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: Metadata writtenback notification? -- was Re: fscache:
 Redesigning the on-disk cache
Message-ID: <20210308232018.GG3479805@casper.infradead.org>
References: <CAOQ4uxjYWprb7trvamCx+DaP2yn8HCaZeZx1dSvPyFH2My303w@mail.gmail.com>
 <2653261.1614813611@warthog.procyon.org.uk>
 <CAOQ4uxhxwKHLT559f8v5aFTheKgPUndzGufg0E58rkEqa9oQ3Q@mail.gmail.com>
 <517184.1615194835@warthog.procyon.org.uk>
 <584529.1615202921@warthog.procyon.org.uk>
 <20210308223247.GB63242@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210308223247.GB63242@dread.disaster.area>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 09, 2021 at 09:32:47AM +1100, Dave Chinner wrote:
> On Mon, Mar 08, 2021 at 11:28:41AM +0000, David Howells wrote:
> >      Possibly it's sufficient to just clear the excess page space before
> >      writing, but that doesn't necessarily stop a writable mmap from
> >      scribbling on it.
> 
> We can't stop mmap from scribbling in it. All filesystems have this
> problem, so to prevent data leaks we have to zero the post-eof tail
> region on every write of the EOF block, anyway.

That's certainly one approach.  Another would be to zero it during the I/O
completion handler.  It depends whether you can trust the last writer or
not (eg what do we do with an isofs file that happens to contain garbage
after the last byte in the file?)
