Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48782 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933532Ab2ERABe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 20:01:34 -0400
Received: by pbbrp8 with SMTP id rp8so3180747pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 17:01:34 -0700 (PDT)
Message-ID: <4FB5915B.2020800@flameeyes.eu>
Date: Thu, 17 May 2012 17:01:31 -0700
From: =?UTF-8?B?RGllZ28gRWxpbyBQZXR0ZW7Dsg==?= <flameeyes@flameeyes.eu>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] build: avoid AM_CONDITIONAL in conditional
 execution.
References: <1337297671-9614-1-git-send-email-flameeyes@flameeyes.eu> <F2544999-60EA-4192-90D5-44C79DEE82CC@oracle.com>
In-Reply-To: <F2544999-60EA-4192-90D5-44C79DEE82CC@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Il 17/05/2012 17:00, Chuck Lever ha scritto:
> Are we using sqlite3 at all at this point?

As far as I can tell it's still a requisite for nfsdcld... I honestly
haven't looked at the code yet simply because I don't use NFSv4 at all
(which is why I found this build failure).

-- 
Diego Elio Pettenò — Flameeyes
flameeyes@flameeyes.eu — http://blog.flameeyes.eu/
