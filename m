Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58569 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbbAOPR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jan 2015 10:17:28 -0500
Date: Thu, 15 Jan 2015 07:17:28 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfs: fix dio deadlock when O_DIRECT flag is flipped
Message-ID: <20150115151728.GA10932@infradead.org>
References: <1421244543-32539-1-git-send-email-tao.peng@primarydata.com>
 <20150114154838.GA15323@infradead.org>
 <CAKVebiUx+WMku--vyRC5h6-8vZ27vOoqVVyfpEmwztJaqvAx9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiUx+WMku--vyRC5h6-8vZ27vOoqVVyfpEmwztJaqvAx9g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 15, 2015 at 12:55:35AM +0800, Peng Tao wrote:
> > The right fix is to determine the O_DIRECT flag in one place when
> > entering a write, and then pass it down on the stack.  We already do
> > this in XFS for example, it just needs to be expanded to filemap.c
> > so that more filesystems benefit from it.
> NFS hijacks DIO in ->write_iter by checking O_DIRECT flag and rely on
> generic_file_write_iter() for buffer write. generic_file_write_iter()
> again checks for O_DIRECT flag.... It seems that we can avoid the
> double check on O_DIRECT flag by calling generic_perform_write()
> instead.

Yes, that sounds like the simplest version for now.
