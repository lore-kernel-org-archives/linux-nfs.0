Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33758 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984AbbHRV6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 17:58:25 -0400
Received: by wijp15 with SMTP id p15so111433615wij.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 14:58:24 -0700 (PDT)
Received: from [192.168.1.188] (ipbcc14f0f.dynamic.kabel-deutschland.de. [188.193.79.15])
        by smtp.gmail.com with ESMTPSA id l13sm28226394wjr.18.2015.08.18.14.58.23
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 14:58:23 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Tastky <tastky@gmail.com>
Subject: [BUG] nfs-utils broken with musl
Message-ID: <55D3AA7E.2050606@gmail.com>
Date: Tue, 18 Aug 2015 23:58:22 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As currently being discussed on musl's mailing list, there appears to be 
a bug in nfs-utils exposed by musl, which makes rpc.statd loop with:

my_svc_run() - select: Bad file descriptor

URL to list:
http://www.openwall.com/lists/musl/2015/08
The relevant messages begin at August 18 and have 'nfs-utils broken with 
musl: "select: Bad file descriptor"' in their titles.
