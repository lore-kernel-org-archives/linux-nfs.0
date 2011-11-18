Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53738 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933Ab1KRN57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 08:57:59 -0500
Received: by fagn18 with SMTP id n18so4304340fag.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 Nov 2011 05:57:58 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Fri, 18 Nov 2011 14:57:58 +0100
Message-ID: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
Subject: server reboot recovery is broken with 3.1 (3.2?) with nfsv41 clients
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear  nfs hackers,

it looks like with kernel 3.1 client cant recover from server reboots.
The nfs mount hangs and there are no packages sent from a client to the server.
This was IO with pnfs.

Regards,
   Tigran.
