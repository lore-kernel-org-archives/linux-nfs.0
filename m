Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34311 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753128AbcLAQvw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 11:51:52 -0500
Received: by mail-io0-f169.google.com with SMTP id c21so396663522ioj.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 08:51:52 -0800 (PST)
MIME-Version: 1.0
From: Joachim Banzhaf <joachim.banzhaf@googlemail.com>
Date: Thu, 1 Dec 2016 17:51:49 +0100
Message-ID: <CABW3MLd5Bo-xBtLqtB4e-pD2hCYAuRaBBsqBFTiws5-HohjPTw@mail.gmail.com>
Subject: rpcbind allowed port range on linux
To: linux-nfs@vger.kernel.org
Cc: "joachim.banzhaf" <joachim.banzhaf@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi list,

my problem is, rpcbind gave a tcp port to nlockmgr where I assumed
this port is reserved.

Now, I didn't find the spec that says which ports rpcbind is allowed
to use, but I thought it is the ephemeral ports, on linux defined with
the range in kernel configuration net.ipv4.ip_local_reserved_ports
minus exclusions from net.ipv4.ip_local_reserved_ports.

So, my questions are
1) Is my assumption about allowed ports correct?
2) If not: how can I define that range?
3) If yes: was there a fix for that since my rather old SLES 12
version rpcbind-0.2.1_rc4 (kernel 3.12.55)? I didn't find something
obvious to me in the changelog.

Bonus question: would it have been safe/possible to free up the port,
e.g. with rpcbind -d? I only found out about that option after a
reboot...

BR,
Joachim

(please keep me in cc)
