Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25352 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755755Ab0JDMuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 08:50:54 -0400
Message-ID: <4CA9CDA8.4010407@parallels.com>
Date: Mon, 04 Oct 2010 16:50:48 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/13] sunrpc: Compact the xprtsock code a bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi!

This set removes some unused parts of code and merges together
routines that are related to the sockets creation.

After all the changes the result is

 net/sunrpc/xprtsock.c: 77 insertions(+), 206 deletions(-)

from the code-lines point of view and

  add/remove: 2/11 grow/shrink: 4/1 up/down: 879/-1626 (-747)

from the bloat-o-meter's point of view.

Thanks,
Pavel
