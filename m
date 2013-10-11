Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56538 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759226Ab3JKTrs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Oct 2013 15:47:48 -0400
Date: Fri, 11 Oct 2013 12:47:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
Message-ID: <20131011194746.GB4941@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been looking at this patch and the surrounding code a bit more and
start to really dislike it.

put_nfs4_file is very much unrelated to the state lock, so having a
version that internally drops it seems wrong.  If we look at the usage
of your new locked version there's very few callers:


 put_nfs4_file_locked
  + destroy_layout_state
     + put_layout_state
        + destroy_layout
	  + destroy_layout_list
	     + nfs4_pnfs_return_layout
	     + pnfs_expire_client
	+ nfs4_pnfs_get_layout
	+ nfs4_pnfs_return_layout

Except for pnfs_expire_client all these are right near the places where
the state lock is dropped, so simply refactoring the code sounds like
a very valid option.


And btw, the state locking is even more of a mess than I though.  I
think it really needs to be split up sooner or later.

