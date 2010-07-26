Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41343 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab0GZQ2T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 12:28:19 -0400
Received: by wyf19 with SMTP id 19so2270866wyf.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jul 2010 09:28:18 -0700 (PDT)
Date: Mon, 26 Jul 2010 11:28:16 -0500
Message-ID: <AANLkTinSoYMPyJVatsrOycXoevreXhxoKBiYXzC4XhWH@mail.gmail.com>
Subject: Recommendation of SAN devices
From: Peng Yu <pengyu.ut@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'm not sure if this is the appropriate for this mailing list. But I
just ask in case anybody has some knowledge.

Essentially, I want to build a cluster where multiple machines
(multi-core) access the same cluster file system. Each machine might
concurrently access the same file system for writing or reading. The
processes running on these machines are I/O intensity. I think that if
machines have all CPU used, the total I/O read/write usage could be
hundred of MB/s. I want the whole system be scalable in the sense that
more machines can be added without making the I/O the bottleneck.

The SRX model in the following webpage is a choice. However, I'd like
to see all the possible choices from different vendors so that I can
make a more informative decision. Could you please share me some
insights that you have or point me to a mailing list where I might get
some answers?

http://www.coraid.com/products/index.html

-- 
Regards,
Peng
