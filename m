Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33564 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981AbbIYLIM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 07:08:12 -0400
Received: by wiclk2 with SMTP id lk2so17094714wic.0
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 04:08:00 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 25 Sep 2015 16:38:00 +0530
Message-ID: <CAPrqf91jVM8jq2-u9TBNPx4nc2pmPct-PYqGWau4mcQQOT_Lmg@mail.gmail.com>
Subject: Tool or module to test NFSv3 server scalability
From: Pankaj Singh <psingh.ait@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I am new to nfs. I have a requirement to test the scalability of NFSv3.
To test this I would require a solution that can simulate multiple nfs clients.
As its known a single TCP connection is used for communication between
client and server. So to increase multiple connections multiple
nfs-clients would be needed. Which is very costly.

So would need some method/tool to create multiple nfs TCP connections
from single or few machines.

-- 
Regards,
Pankaj SIngh
