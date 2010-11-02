Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:55694 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169Ab0KBOF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 10:05:26 -0400
Date: Tue, 2 Nov 2010 10:05:22 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Eric Anderle <eanderle@umich.edu>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils: Various bug fixes and cleanups to blkmapd
Message-ID: <20101102140522.GA23409@merit.edu>
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

My patches are all in your pnfs-nfs-utils-1-2-3-2010-10-08 but are missing
after that.  I will re-send.

% git shortlog --author=rees@umich pnfs-nfs-utils-1-2-3-2010-10-08
Jim Rees (5):
      Add complex block layout discovery and mapping daemon
      blkmapd: get rid of config file and instead examine all block devices
      blkmapd: don't rescan periodically
      blkmapd: don't use atomicio() where it's not needed
      blkmapd: don't try to distinguish between active/passive devices

% git shortlog --author=rees@umich origin/master
Jim Rees (1):
      Add complex block layout discovery and mapping daemon
