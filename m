Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:52643 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab2E1TU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 15:20:29 -0400
Date: Mon, 28 May 2012 15:20:21 -0400
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: Trond.Myklebust@netapp.com, Boaz Harrosh <bharrosh@panasas.com>,
        linux-nfs@vger.kernel.org, stable@vger.kernel.org,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH] pnfsblock: bail out partial page IO
Message-ID: <20120528192021.GA14447@umich.edu>
References: <1338228443-4883-1-git-send-email-bergwolf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1338228443-4883-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peng Tao wrote:

  Current block layout driver read/write code assumes page
  aligned IO in many places. Add a checker to validate the assumption.

This patch has some problems when compiled for 64 bit.

  CC [M]  fs/nfs/blocklayout/blocklayout.o
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c: In function ‘bl_read_pagelist’:
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c:255:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c: In function ‘bl_write_pagelist’:
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c:578:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c: In function ‘bl_pg_init_read’:
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c:1017:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c: In function ‘bl_pg_init_write’:
/home/rees/src/pnfs/linux/fs/nfs/blocklayout/blocklayout.c:1026:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
