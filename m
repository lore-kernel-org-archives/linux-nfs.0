Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36399 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbCXMTZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 08:19:25 -0400
Received: by igbud6 with SMTP id ud6so69808438igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2015 05:19:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAL8eLxVyJYiSmVL1FP6eFNmMQCQZRHO+rYP5Wvv9cyZ+DU_jiQ@mail.gmail.com>
References: <CAL8eLxVyJYiSmVL1FP6eFNmMQCQZRHO+rYP5Wvv9cyZ+DU_jiQ@mail.gmail.com>
Date: Tue, 24 Mar 2015 17:49:25 +0530
Message-ID: <CAL8eLxW7_B=_B-h2Ph_dgWf4nmcNmG8DZoi7BqPYc3y95EcMTg@mail.gmail.com>
Subject: Fwd: nfs.5: Add addr mount option for all nfs versions
From: Abhijit Pal <21.abhijit@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello linux-nfs team,

Thank you for giving your attention and time to my query.

Wanted to get an insight about a problem regarding nfs mount using the
system call mount(2) which was reported by one of the user in
"StackOverflow".

The URL for the problem statement and the accepted solution is:
http://stackoverflow.com/questions/28350912/nfs-mount-system-call-in-linux

After going through the kernel code(v 3.18.6), I have posted an answer
which worked for the user and was accepted. Was thinking if you can
guide me if the accepted solution is indeed a bug or not. And if the
solution is acceptable would request you to kindly let me know the
process, so that I can send a patch for updating the nfs(5) man page.

Thanks
Abhijit
