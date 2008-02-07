From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: nfs new_cache mechanism and older kernel
Date: Thu, 7 Feb 2008 15:19:19 -0800
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C5798775@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:30716 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934642AbYBGXUS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2008 18:20:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi:

I am wondering if there is a known issue with using the newer cache
mechanism in NFS (by mounting nfsd filesystem on /proc/fs/nfsd) on an
older kernel like 2.6.17 built for 64 bit archs. I am observing a
peculiar problem. The moment nfs exportfs writes the time value from
time() system call to <cache>/flush, the exports entries vanishes.
However, when I pass smaller arbitrary values (of the order of 100s or
10000s), the tables do not get cleared. This could be (though I am not
completely sure) due to the difference between what sys_time() reports
and what get_seconds() reports. Get_seconds() reports the seconds from
the xtime structure whereas sys_time uses do_gettimeofday() in 2.6.17
kenrel. But I could be wrong. Any thoughts on this? 

Ani

