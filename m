Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bossdog.realss.com ([211.157.114.130]:42120 "EHLO
	bossdog.realss.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab0I0Izg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 04:55:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by bossdog.realss.com (Postfix) with ESMTP id B176D24816E
	for <linux-nfs@vger.kernel.org>; Mon, 27 Sep 2010 16:47:12 +0800 (HKT)
Received: from bossdog.realss.com ([127.0.0.1])
	by localhost (bossdog.realss.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id iDPOEeBCBffr for <linux-nfs@vger.kernel.org>;
	Mon, 27 Sep 2010 16:47:12 +0800 (HKT)
Received: from [192.168.0.4] (unknown [202.43.159.183])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by bossdog.realss.com (Postfix) with ESMTPSA id 55B7E2480DA
	for <linux-nfs@vger.kernel.org>; Mon, 27 Sep 2010 16:47:12 +0800 (HKT)
Message-ID: <4CA05749.8070502@realss.com>
Date: Mon, 27 Sep 2010 16:35:21 +0800
From: Zhang Weiwu <zhangweiwu@realss.com>
To: linux-nfs@vger.kernel.org
Subject: when will we be able to use LIPKEY on NFS4 on Linux?
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello.

Quote from 2006 article:
http://www.ibm.com/developerworks/systems/library/es-nfs-security/index.html#N100AF

    In /a few years/, NFS Version 4 implementations will start claiming
    support for the public key-based security mechanism (SPKM and LIPKEY).


My question:

   1. Is LIPKEY already implemented in some NFS4 implementation?
      Particularly, I am interested using it on Debian Linux.
   2. I could not manage to find a how-to on using LIPKEY, e.g. where to
      store the public key and certificates, where to configure
      username/password for client authentication. Is there one existing?

Thanks in advance!

