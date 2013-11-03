Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61069 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab3KCLuu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Nov 2013 06:50:50 -0500
Received: by mail-pa0-f45.google.com with SMTP id kp14so5859621pab.32
        for <linux-nfs@vger.kernel.org>; Sun, 03 Nov 2013 03:50:50 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 3 Nov 2013 13:50:50 +0200
Message-ID: <CADtAWjC5PWixao_aPuqSiPxPSqhwN8PShQf7Jctua9aqzjc_YA@mail.gmail.com>
Subject: rpc.idmapd plugin for sssd
From: Noam Meltzer <tsnoam@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I was thinking of writing a plugin for rpc.idmapd which will retrieve
the required information from SSSD (https://fedorahosted.org/sssd/)

Before doing so, I just wanted to make sure that no one here is aware
of an existing plugin?

Best regards,
Noam Meltzer
