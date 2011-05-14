Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:44965 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab1ENWBP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2011 18:01:15 -0400
Date: Sat, 14 May 2011 18:01:09 -0400
From: Jim Rees <rees@umich.edu>
To: Weston Andros Adamson <dros@netapp.com>
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: pnfs IPv6 support
Message-ID: <20110514220109.GA3910@merit.edu>
References: <1305407199-15206-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1305407199-15206-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Weston Andros Adamson wrote:

  +	if (!rpc_ntop((struct sockaddr *)&ds->ds_addr, buf, sizeof(buf))) {
  +		dprintk("%s: error printing addr\n", __func__);
  +		return;
  +	}

Interesting.  How come there's no ntop() in net/core/utils.c?
