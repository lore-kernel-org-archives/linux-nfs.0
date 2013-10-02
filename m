Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44222 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab3JBQIA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 12:08:00 -0400
Date: Wed, 2 Oct 2013 09:07:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131002160759.GB27988@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220810-12909-1-git-send-email-bhalevy@primarydata.com>
 <20130929114327.GB25750@infradead.org>
 <52481939.7060405@primarydata.com>
 <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
 <20130929122130.GI21083@infradead.org>
 <20130929123553.GA7510@infradead.org>
 <20131001203047.GH16245@pad.fieldses.org>
 <524C0556.9070705@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524C0556.9070705@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 02:36:54PM +0300, Benny Halevy wrote:
> I suggest moving the code in fs/nfsd/nfs4pnfsdlm.c to
> fs/dlm.

I don't reall care where in the tree it lives, but it needs to be
neither part of nfsd or the filesystem (respectively dlm in this case).

