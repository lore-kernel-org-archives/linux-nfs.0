From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Congestion window or other reason?
Date: Fri, 26 Sep 2008 15:16:11 -0400
Message-ID: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1960 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751925AbYIZTQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 15:16:15 -0400
Received: from scott-wlan.sw.myri.com (scott-wlan.sw.myri.com [172.31.162.6])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m8QJGC60005081
	for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2008 12:16:12 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I have bulk writing and reading working on RPCMX, sort of.

Reading seems to work fine. Writing seems to work fine if  
RPCMX_MAX_DATA_SEGS is set to <=32 (versus the default of 8 in  
RPCRDMA). Above that value, I get an oops on the server.

Reading seems to work fine with values up to 128. I have not tried  
256, because the code then adds 2 to create RPCMX_MAX_SEGS and MX is  
limited to 256 total segments. I tried 254, but the client seems to  
prefer power of 2 values, so it uses 128 pages (512 KB).

As best I can tell when reading a 1 MB file, the first transfer is 32  
pages, the second transfer is 128 pages, and the final transfer is the  
remaining 96 pages.

When writing, the client tries to send 128 pages twice. The SVC MX  
layer receives them correctly (it parses the request correctly and  
posts 128 pages), but I get an oops in svc_process().

Is this related to the congestion window or something else? It doesn't  
come up in RPCRDMA since it is limited to 8 pages.

Any advice would be great.

Thanks,

Scott


--
Scott Atchley
Myricom Inc.
http://www.myri.com


