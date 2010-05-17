From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/2] get rid of threshold policy ops
Date: Mon, 17 May 2010 23:51:47 +0300
Message-ID: <4BF1AC63.8000301@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:54274 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab0EQUvy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 16:51:54 -0400
Received: by wwb39 with SMTP id 39so114739wwb.19
        for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 13:51:52 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following Andy's "pnfs_submit:: Remove threshold calculations" patchset:
http://marc.info/?l=linux-nfs&m=127367698029679&w=2

I obliterated the threshold methods from the objects and blocks layout
drivers as follows:

[PATCH 1/1] SQUASHME: pnfs-obj: get rid of threshold policy ops
[PATCH 2/2] SQUASHME: pnfsblock: get rid of threshold policy ops
