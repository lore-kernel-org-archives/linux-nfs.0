Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from woodbine.london.02.net ([87.194.255.145]:42420 "EHLO
	woodbine.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab0IPV06 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Sep 2010 17:26:58 -0400
Received: from [192.168.1.64] (87.194.12.203) by woodbine.london.02.net (8.5.124.10)
        id 4C8D7834001812F9 for linux-nfs@vger.kernel.org; Thu, 16 Sep 2010 22:18:50 +0100
Message-ID: <4C9289B5.8050002@limepepper.co.uk>
Date: Thu, 16 Sep 2010 22:18:45 +0100
From: Tom <tom@limepepper.co.uk>
To: linux-nfs@vger.kernel.org
Subject: how to limit disk IO utilization by the nfs server?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hi,

I would like to throttle the nfs server's IO utilization as when its at 
100% its causing problems, and I would like to restrict the clients.

Any suggestions on how I can do this?

Thanks
Tom
