From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: linux client support for pnfs over ipv6
Date: Tue, 17 May 2011 15:28:46 -0400
Message-ID: <BANLkTi=juxkPqEXtSNubnOFHWT7FLzPdGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Groshans <groshans@umich.edu>,
	peter honeyman <honey@citi.umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63518 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756496Ab1EQT2q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2011 15:28:46 -0400
Received: by iyb14 with SMTP id 14so685786iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2011 12:28:46 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there a plan to support ipv6 pnfs on the linux client side?

kernel output on the client has:
kernel: decode_and_add_ds: Only ipv4 addresses supported
