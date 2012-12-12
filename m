Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40357 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab2LLIiM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2012 03:38:12 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so1171272ieb.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2012 00:38:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJfNFaUtTN4EXhuL87xgF2p7fdqPPVcf50=9ZkY440kmi263DA@mail.gmail.com>
References: <CAJfNFaUtTN4EXhuL87xgF2p7fdqPPVcf50=9ZkY440kmi263DA@mail.gmail.com>
Date: Wed, 12 Dec 2012 16:38:11 +0800
Message-ID: <CAJfNFaXTtRj9RKRMK06gQEpSPDCuhphF_7H=cHpCAVnMG7zM3Q@mail.gmail.com>
Subject: Fwd: How can I mount an NFSv4 for root?
From: Xinyu Chen <muddogxp@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

I want to mount a rootfs which is exported as NFSv4. I tried to pass
'v4' option to nfsroot= in the kernel command line, but it does not
work.
I google some threads about this topic, someone told that nfsroot
kernel parameter does not support NFSv4 anymore, is it true?
Then how can I mount a NFSv4 filesystem as a rootfs directly from
kernel commandline?

--
Best Regards
Xinyu Chen
