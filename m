From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Lock problem.
Date: Thu, 11 Oct 2007 10:37:48 -0400
Message-ID: <EXNANE01zwWJv3zOdnj000006bc@exnane01.hq.netapp.com>
References: <470DE540.1090908@charta.it>
	<18189.63030.815930.43180@notabene.brown>
	<470E2012.5020808@charta.it>
	<EXNANE011B6gVs1tIzm000006ba@exnane01.hq.netapp.com>
	<470E3226.4080706@charta.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "matteo.debiaggi" <matteo.debiaggi@charta.it>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfzBP-0001eD-Ro
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 07:38:40 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfzBS-0001xU-VX
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 07:38:45 -0700
In-Reply-To: <470E3226.4080706@charta.it>
References: <470DE540.1090908@charta.it>
	<18189.63030.815930.43180@notabene.brown>
	<470E2012.5020808@charta.it>
	<EXNANE011B6gVs1tIzm000006ba@exnane01.hq.netapp.com>
	<470E3226.4080706@charta.it>
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

At 10:24 AM 10/11/2007, matteo.debiaggi wrote:
>The 2 machines are in a local net without any kind of firewalls ..
>But the problem "seems" to be solved :
>I think the problem is in lockd daemon.
>Explained 30 sec waiting :  2 locks request with default timeout 15 sec..
>And then  why lock  not gained on server? Maybe due to max concurrent 
>threads asking fo lock to lockd daemon where the default is 20!My test 
>implyies 2000 lines writing on file with a pause of 10000 us between 
>write attempt and reading every 100ms.So 20 lock requests  queued are a 
>possible context.
>I restarted lockd daemon with 100  as  maximum contemporary lock 
>requests from threads and test goes fine.

Is this some kind of Solaris server option? Yuck.

Anyway, I still think you need to understand why you got the ICMP port
unreachable from the client. It will come back, I predict...

Tom.

>Thanks to everybody.
>I hope not to face  this problem again after this modify.
>Matteo.
>
>p.s. i can't get nlm decoding from tcpdump..
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
