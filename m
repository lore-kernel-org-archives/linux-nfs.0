Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37690 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbcEZIfu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2016 04:35:50 -0400
Received: by mail-wm0-f50.google.com with SMTP id z87so89896797wmh.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2016 01:35:49 -0700 (PDT)
MIME-Version: 1.0
From: Satya Prakash GS <g.satyaprakash@gmail.com>
Date: Thu, 26 May 2016 14:05:29 +0530
Message-ID: <CAJZK4X4r2WMCqfBsxxswJ95Sznu6TfJk5bBsti_je92ieYnipw@mail.gmail.com>
Subject: reg. stale post attributes
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have been going through NFS client code and looks like most of the
file operations get post attributes and client applies them after
checking for freshness. How does this scheme work when 2 ops modify
the same attribute on the server ? If op1 and op2 replies come out of
order from server or are applied on server out of order how does the
logic for freshness ensure that the client has the correct attributes.
Sorry, I am not a kernel expert and I could not quote examples for op1
and op2, I am trying to understand the behaviour from the file system
perspective logically.

Thanks,
Satya.
