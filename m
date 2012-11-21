Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm13-vm5.bullet.mail.sg3.yahoo.com ([106.10.149.20]:31783 "EHLO
	nm13-vm5.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751901Ab2KUHPy convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Nov 2012 02:15:54 -0500
References: <1353478789.45781.YahooMailNeo@web190601.mail.sg3.yahoo.com>
Message-ID: <1353481761.28049.YahooMailNeo@web190605.mail.sg3.yahoo.com>
Date: Wed, 21 Nov 2012 15:09:21 +0800 (SGT)
From: Kks Kbase <kks.kbase@yahoo.in>
Reply-To: Kks Kbase <kks.kbase@yahoo.in>
Subject: showmount -e  issue
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1353478789.45781.YahooMailNeo@web190601.mail.sg3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi,


I tried to configure NFS today and I exported the share I tried to see 
the exports shares using showmount -e but it throws some errors.

# showmount -e
mount clntudp_create: RPC: Port mapper failure - RPC: Timed out

May I know what's causing the issue?
