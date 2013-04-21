Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:46543 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176Ab3DUINu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Apr 2013 04:13:50 -0400
Received: by mail-pa0-f44.google.com with SMTP id bi5so3032785pad.3
        for <linux-nfs@vger.kernel.org>; Sun, 21 Apr 2013 01:13:49 -0700 (PDT)
Date: Sun, 21 Apr 2013 16:13:27 +0800
From: "linux.pnfs" <linux.pnfs@gmail.com>
To: "linux-nfs" <linux-nfs@vger.kernel.org>
Subject: pNFS layered over cluster FS, is this the status quo?
Message-ID: <201304211613254596282@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pNFS layered over cluster FS(such as GFS2), DLM implement layoutget(a pnfs export operations) but it not support IOMODE_RW, that is write data must via meta data server, -->> is this the status quo?

the MDS' layoutget will support IOMODE_RW and client will RW data via data server in the future?
or is there any support for: howto parellel R&W data via data server?

thanks!

