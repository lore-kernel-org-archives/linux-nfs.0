Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63713 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755840Ab0J1TSx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 15:18:53 -0400
Received: by bwz11 with SMTP id 11so1887700bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 12:18:51 -0700 (PDT)
Date: Thu, 28 Oct 2010 15:18:51 -0400
Message-ID: <AANLkTinDvgLsjwdz4PhmrRO=R+yAc23+8iP==Hvferrq@mail.gmail.com>
Subject: [PATCH 0/6] pnfs callback rewrite preparation
From: Fred Isaman <iisaman@netapp.com>
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These patches prepare the way for a rewrite of the cb_layoutrecall
code, patch 3 in particular.  They apply onto Benny's pnfs-submit
branch.

I'm still cleaning up the cb_recall patches.  Hopefully I'll
send thoe tomorrow.

Fred
