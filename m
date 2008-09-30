From: Just Marc <marc-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Subject: Re: lockd using up 60% CPU and won't let go
Date: Mon, 29 Sep 2008 20:18:10 -0400
Message-ID: <48E17042.101@corky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:56563 "EHLO zebday.corky.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751908AbYI3ASO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 20:18:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

 > It's basically just a userspace NFS server, right?

Correct.

 > Could you work around the problem by mounting with -onolock?

That doesn't seem to help.

 >You might try running wireshark on the "lo" interface and seeing 
whether there's any NLM traffic from lockd.

You guessed right.   There's a 12 megabytes per second of NLM traffic on lo.

unlock call requests and unlock replies saying permission denied, looks 
like it just repeats forever in a tight loop.

Marc
