Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35072 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791Ab3JCGCb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 02:02:31 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so1891656wgh.3
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 23:02:30 -0700 (PDT)
Message-ID: <524D0873.40602@primarydata.com>
Date: Thu, 03 Oct 2013 09:02:27 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org> <20131001203047.GH16245@pad.fieldses.org> <524C0556.9070705@primarydata.com> <20131002160759.GB27988@infradead.org>
In-Reply-To: <20131002160759.GB27988@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-02 19:07, Christoph Hellwig wrote:
> On Wed, Oct 02, 2013 at 02:36:54PM +0300, Benny Halevy wrote:
>> I suggest moving the code in fs/nfsd/nfs4pnfsdlm.c to
>> fs/dlm.
> 
> I don't reall care where in the tree it lives, but it needs to be
> neither part of nfsd or the filesystem (respectively dlm in this case).

Just that this is dlm specific logic.
For example, using dlm_ino_hash() in nfsd4_pnfs_dlm_layoutget().
Or even knowing that
	layout->lg_stripe_type = STRIPE_SPARSE;
assumes knowledge of the underlying cluster fs implementation.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
