Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58629 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754350AbaFIXp0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 19:45:26 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id E524821765
	for <linux-nfs@vger.kernel.org>; Mon,  9 Jun 2014 19:45:24 -0400 (EDT)
Date: Mon, 9 Jun 2014 16:49:11 -0700
From: Greg KH <greg@kroah.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Weng Meiling <wengmeiling.weng@huawei.com>, stable@vger.kernel.org,
        lizefan@huawei.com, skinsbursky@parallels.com, h.huangqiang@huawei.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3.4 0/9] fix the NULL pointer when use nfs in diferent
 net ns
Message-ID: <20140609234911.GB377@kroah.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
 <20140504123011.GE21635@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140504123011.GE21635@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 04, 2014 at 08:30:11AM -0400, J. Bruce Fields wrote:
> ACK to these for stable.--b.

All now queued up, thanks.

greg k-h
