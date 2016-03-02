Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45567 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbcCBQhs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2016 11:37:48 -0500
Date: Wed, 2 Mar 2016 08:37:46 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs  support servers with multiple layout types
Message-ID: <20160302163746.GA25527@infradead.org>
References: <1456920492-22533-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1456927079-4788-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456927079-4788-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	for(i = 0; i < num && i < NFS_MAX_LAYOUT_TYPES; i++)
> +		layouttype[i] = be32_to_cpup(p++);

Can we use a bitmap and do something like

	layouttype |= (1 << be32_to_cpup(p++));

that's what I did for my unsubmitted patches to submit multiple
layouttypes in the Linux server..
