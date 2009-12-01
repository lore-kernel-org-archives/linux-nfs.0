From: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Subject: rpc.statd problem: lockd: cannot monitor server
Date: Tue, 01 Dec 2009 18:14:15 +0100
Message-ID: <4B154EE7.8050700@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:36878 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbZLARRL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2009 12:17:11 -0500
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id D80996F5E0
	for <linux-nfs@vger.kernel.org>; Tue,  1 Dec 2009 18:17:10 +0100 (CET)
Received: from [129.183.148.90] (frecb001658.frec.bull.fr [129.183.148.90])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id CA7552728D
	for <linux-nfs@vger.kernel.org>; Tue,  1 Dec 2009 18:17:07 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,

We are having a problem with locks in NFSv3 with Fedora11. I've been 
searching this problem in the list for a while but I haven't found it.

The problem is in Fedora11, kernel 2.6.29.6-217.2.16.fc11 and 
nfs-utils-1.1.5-6.fc11

When I try to make two locks with two different process I get the 
message "No locks available". rpc.statd is running on client and server, 
also lockd. If I try with just one process I obtain the same result.

I tried to debug with wireshark and I can see client is not trying to 
make a lock. I also tried to enable NLM debug and I get next messages:

Syslog:

1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: get 
host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: get 
host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
nsm_monitor(myserver)
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: get 
host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: get 
host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
nsm_monitor(myserver)
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
xdr_dec_stat_res status 1 state -1
1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd: 
cannot monitor myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
release host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
release host myserver
1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd 
creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or directory
1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd 
STAT_FAIL to myclient for SM_MON of 10.0.4.60
1259574201 2009 Nov 30 10:43:21 myclient daemon warning rpc.statd 
creat(/var/lib/nfs/statd/sm/myserver) failed: No such file or directory
1259574201 2009 Nov 30 10:43:21 myclient daemon notice rpc.statd 
STAT_FAIL to myclient for SM_MON of 10.0.4.60
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: clnt 
proc returns -37
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
xdr_dec_stat_res status 1 state -1
1259574201 2009 Nov 30 10:43:21 myclient kern notice kernel lockd: 
cannot monitor myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
release host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: 
release host myserver
1259574201 2009 Nov 30 10:43:21 myclient kern warning kernel lockd: clnt 
proc returns -37

It's like if rpc.statd was not running, but it is. Should ../statd/sm/ 
directory be already created when we try the lock?

Is this a known problem?

Thanks,
