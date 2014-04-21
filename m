Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59271 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaDUPBO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 11:01:14 -0400
Date: Mon, 21 Apr 2014 08:01:13 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/70] NFSd lock scalability patches
Message-ID: <20140421150113.GA24334@infradead.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think the series introduces some find vs alloc races where a function
first tries to find an existing structure in a lookup structure, then
allocates a new one, but doesn't check for another allocation that could
have happened in the meantime.

 - lookup_or_create_lock_state for lock stateids
 - I can't find any protection for the creation/addition of files
   and open stateids in the whole open machinery
   (nfsd4_open, nfsd4_process_open1 and nfsd4_process_open2), but
   I also generally have trouble following that code.
 - similarly I can't find much of a protection against this sort of
   race for the various state owners.
