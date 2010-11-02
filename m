Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:49157 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750829Ab0KBLep (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 07:34:45 -0400
Date: Tue, 2 Nov 2010 07:34:42 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Eric Anderle <eanderle@umich.edu>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils: Various bug fixes and cleanups to blkmapd
Message-ID: <20101102113442.GA8716@merit.edu>
References: <20101029153637.GA31961@merit.edu>
 <4CCFB107.1090600@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CCFB107.1090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  There are conflicts merging this patch as bldev_read_ap_state
  is already defined (in "Add complex block layout discovery and mapping daemon")
  I'm not sure how, but we seem out of sync, maybe I didn't get an earlier patch
  of yours.

I think it was removed in "blkmapd: don't try to distinguish between
active/passive devices" from Oct 8.  No problem, I'll fix it and send new
patches.
