Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45801 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbaHGHYa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:24:30 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XFI3p-0006zZ-Ae
	for linux-nfs@vger.kernel.org; Thu, 07 Aug 2014 07:24:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils: blkmapd fixex
Date: Thu,  7 Aug 2014 09:26:47 +0200
Message-Id: <1407396409-5036-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixed the broken ѕupport for dm-multipath devices in blkmapd, and
adds some useful logging to syslog that allows triaging pnfs block layout setup
issues.

This work was sponsored by NetApp, Inc.
