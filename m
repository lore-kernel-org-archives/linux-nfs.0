Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58548 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab0JUQcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 12:32:35 -0400
Date: Thu, 21 Oct 2010 12:32:34 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 2.6.37 nfsd changes
Message-ID: <20101021163234.GA23584@infradead.org>
References: <20101021162306.GA9537@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101021162306.GA9537@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Pavel Emelyanov (37):
>       nfsd: Export get_task_comm for nfsd

NAK.  As mentioned in the reply to the patch series nfsd should
just use current->comm.

