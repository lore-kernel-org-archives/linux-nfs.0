From: "matteo.debiaggi" <matteo.debiaggi@charta.it>
Subject: Re: Lock problem.
Date: Thu, 11 Oct 2007 15:07:30 +0200
Message-ID: <470E2012.5020808@charta.it>
References: <470DE540.1090908@charta.it>
	<18189.63030.815930.43180@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfxlN-0000qf-11
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:07:41 -0700
Received: from [213.209.214.162] (helo=charta.it)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfxlM-0006Jl-5g
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:07:46 -0700
In-Reply-To: <18189.63030.815930.43180@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Well, the result of tcpdump of the packets seen in the uncorrect lock 
scenario

14:48:56.154531 CLIENT.3542368298 > SERVER.nfs: 108 getattr [|nfs] (DF)
14:48:56.154984 SERVER.nfs > CLIENT.3542368298: reply ok 112 getattr 
[|nfs] (DF)
14:48:56.155158 CLIENT.3559145514 > SERVER.nfs: 112 access [|nfs] (DF)
14:48:56.155307 SERVER.nfs > CLIENT.3559145514: reply ok 120 access 
[|nfs] (DF)
// FIRST LOCK
14:48:56.155423 CLIENT.1022 > SERVER.lockd:  udp 180 (DF)
14:48:56.155713 SERVER.lockd > CLIENT.1022:  udp 36 (DF)
14:48:56.163972 SERVER.823 > CLIENT.34865:  udp 164 (DF)
14:48:56.164156 CLIENT > SERVER: icmp: CLIENT udp port 34865 unreachable 
[tos 0xc0]
14:48:57.096559 arp who-has SERVER tell CLIENT
14:48:57.096618 arp reply SERVER is-at xxxxxxxxxxx
14:49:16.156340 SERVER.756 > CLIENT.sunrpc:  udp 84 (DF)
14:49:16.156598 CLIENT.sunrpc > SERVER.756:  udp 28 (DF)
14:49:16.156872 SERVER.823 > CLIENT.34865:  udp 164 (DF)
14:49:16.157078 CLIENT > SERVER: icmp: CLIENT udp port 34865 unreachable 
[tos 0xc0]
14:49:21.157083 arp who-has SERVER tell CLIENT
14:49:21.157136 arp reply SERVER is-at xxxxxxxxxx
14:49:26.157197 CLIENT.1022 > SERVER.lockd:  udp 180 (DF)
14:49:26.157637 SERVER.lockd > CLIENT.1022:  udp 36 (DF)
14:49:26.157830 CLIENT.3575922730 > SERVER.nfs: 112 access [|nfs] (DF)
14:49:26.158025 SERVER.nfs > CLIENT.3575922730: reply ok 120 access 
[|nfs] (DF)
14:49:26.158157 CLIENT.3592699946 > SERVER.nfs: 108 getattr [|nfs] (DF)
14:49:26.158220 SERVER.nfs > CLIENT.3592699946: reply ok 112 getattr 
[|nfs] (DF)
14:49:26.158402 CLIENT.3609477162 > SERVER.nfs: 112 access [|nfs] (DF)
14:49:26.158465 SERVER.nfs > CLIENT.3609477162: reply ok 120 access 
[|nfs] (DF)
14:49:26.158653 CLIENT.3626254378 > SERVER.nfs: 124 lookup [|nfs] (DF)
14:49:26.158717 SERVER.nfs > CLIENT.3626254378: reply ok 240 lookup 
[|nfs] (DF)
14:49:26.158904 CLIENT.3643031594 > SERVER.nfs: 124 lookup [|nfs] (DF)
14:49:26.158960 SERVER.nfs > CLIENT.3643031594: reply ok 240 lookup 
[|nfs] (DF)
14:49:26.159156 CLIENT.3659808810 > SERVER.nfs: 124 remove [|nfs] (DF)
14:49:26.165118 SERVER.nfs > CLIENT.3659808810: reply ok 144 remove 
[|nfs] (DF)
/////SECOND LOCK
14:49:26.165300 CLIENT.1022 > SERVER.lockd:  udp 164 (DF)
14:49:26.165511 SERVER.lockd > CLIENT.1022:  udp 36 (DF)
14:49:26.165661 CLIENT.1022 > SERVER.lockd:  udp 180 (DF)
14:49:26.165867 SERVER.lockd > CLIENT.1022:  udp 36 (DF)
14:49:26.167697 SERVER.905 > CLIENT.34667:  udp 164 (DF)
14:49:26.167898 CLIENT > SERVER: icmp: CLIENT udp port 34667 unreachable 
[tos 0xc0]
14:49:36.153446 SERVER.755 > CLIENT.sunrpc:  udp 84 (DF)
14:49:36.153724 CLIENT.sunrpc > SERVER.755:  udp 28 (DF)
14:49:46.162473 SERVER.754 > CLIENT.sunrpc:  udp 84 (DF)
14:49:46.173694 CLIENT.sunrpc > SERVER.754:  udp 28 (DF)
14:49:46.173900 SERVER.823 > CLIENT.34865:  udp 164 (DF)
14:49:46.174070 CLIENT > SERVER: icmp: CLIENT udp port 34865 unreachable 
[tos 0xc0]
14:49:51.173721 arp who-has SERVER tell CLIENT
14:49:51.173745 arp reply SERVER is-at 0:1:2:9c:74:c1
14:49:56.165858 CLIENT.34867 > SERVER.sunrpc:  udp 88 (DF)
14:49:56.166362 SERVER.sunrpc > CLIENT.34867:  udp 28 (DF)
14:49:56.166547 CLIENT.1022 > SERVER.lockd:  udp 180 (DF)
14:49:56.166922 SERVER.lockd > CLIENT.1022:  udp 36 (DF)
14:49:56.167068 CLIENT.3676586026 > SERVER.nfs: 108 getattr [|nfs] (DF)
14:49:56.167178 SERVER.nfs > CLIENT.3676586026: reply ok 112 getattr 
[|nfs] (DF)
14:49:56.167288 CLIENT.3693363242 > SERVER.nfs: 120 read [|nfs] (DF)
14:49:56.167396 SERVER.nfs > CLIENT.3693363242: reply ok 1036 read 
[|nfs] (DF)
14:49:56.167703 CLIENT.1022 > SERVER.lockd:  udp 164 (DF)
14:49:56.167779 SERVER.lockd > CLIENT.1022:  udp 36 (DF)
14:49:56.167949 CLIENT.3710140458 > SERVER.nfs: 112 access [|nfs] (DF)
14:49:56.168016 SERVER.nfs > CLIENT.3710140458: reply ok 120 access 
[|nfs] (DF)



I've forgot to mention that some times i've got problem in the first 
reader lock too(and it seems the same behaviour).
Do you need a tcpdump more detailed?(launched with wich options?)
Matteo.

P.S. : Yes, unlock followed by lock helps to avoid line reading 
mismatches and havy load tests tell me it is reliable.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
