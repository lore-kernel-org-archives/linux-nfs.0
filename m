Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:54753 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab1ATDHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 22:07:11 -0500
Date: Wed, 19 Jan 2011 22:07:07 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: Callback slot table overflowed
Message-ID: <20110120030707.GA10667@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is this bad?
Jan 19 21:53:27 pdsi7 kernel: Callback slot table overflowed

All I can tell from the code is that xprt_alloc_bc_request() failed, and the
slots are "preallocated during the backchannel setup".  Is there a hard
limit on these slots?  Where is it set?
