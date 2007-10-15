From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfsd closes port 2049
Date: Mon, 15 Oct 2007 14:04:08 -0400
Message-ID: <EXNANE01sVxONvzyJxA000006ff@exnane01.hq.netapp.com>
References: <47139C02.9020009@cineca.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	LKML <linux-kernel@vger.kernel.org>
To: righiandr@users.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhUJJ-00043H-HT
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:05:01 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhUJM-000120-Gg
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:05:06 -0700
In-Reply-To: <47139C02.9020009@cineca.it>
References: <47139C02.9020009@cineca.it>
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

>Oct 13 05:20:56 node0101 kernel: nfsd_acceptable failed at ffff8100c7873700

Sounds like the filesystem became unexported, or unexportable
due to turning off an "x" bit somewhere along the directory tree.
Were all these clients accessing a single mountpoint? Check
/etc/exports, and that directory.

Tom.




At 12:57 PM 10/15/2007, Andrea Righi wrote:
>Hi all,
>
>I'm trying to debug a weird problem with nfsd on a 2.6.16.27-0.6-smp
>kernel.
>
>1 server: SuSE SLES 10 x86_64, config attached
>256 clients: RHEL4 Update 4 2.6.9-42.ELsmp x86_64
>
>Using nfs v3.
>
>The clients have been happily talking to the server for several days
>without incident.
>
>The weird thing is that at a certain point the socket opened on port
>2049 on the NFS server is being closed for unknown reasons (or better
>for unknown reasons for me!). With unknown reasons I mean that I don't
>see any critical error message in the logs, even with debug verbosity
>enabled. I've enabled the max debug verbosity with:
>
>echo 2147483647 > /proc/sys/sunrpc/nfsd_debug
>
>The failures in the accept()s confirms that the server socket is working
>fine and suddenly it has been closed (I did some attempts with a simple
>netcat from localhost to check the socket availability):
>
># bzcat /var/log/messages-20071013.bz2 | grep accept
>Oct 13 00:30:05 node0101 kernel: svc: tcp_accept ffff81015ea1d380 sock 
>ffff81015ce1a780
>Oct 13 00:30:05 node0101 kernel: svc: tcp_accept ffff8100c7997c00 allocated
>Oct 13 00:30:06 node0101 kernel: svc: tcp_accept ffff81015ea1d380 sock 
>ffff81015ce1a780
>Oct 13 00:30:06 node0101 kernel: svc: tcp_accept ffff8100c7997c00 allocated
>Oct 13 00:32:30 node0101 kernel: svc: tcp_accept ffff81015ea1d380 sock 
>ffff81015ce1a780
>Oct 13 00:32:30 node0101 kernel: svc: tcp_accept ffff8100c7997c00 allocated
>Oct 13 00:32:31 node0101 kernel: svc: tcp_accept ffff81015ea1d380 sock 
>ffff81015ce1a780
>Oct 13 00:32:31 node0101 kernel: svc: tcp_accept ffff8100c7997c00 allocated
>Oct 13 05:20:56 node0101 kernel: nfsd_acceptable failed at ffff8100c7873700
>Oct 13 05:51:06 node0101 kernel: nfsd_acceptable failed at ffff8100cba472f0
>Oct 13 09:51:11 node0101 kernel: nfsd_acceptable failed at ffff8100c6dbba40
>Oct 13 11:04:33 node0101 kernel: nfsd_acceptable failed at ffff8100ce485a40
>Oct 13 11:51:30 node0101 kernel: nfsd_acceptable failed at ffff8100c95552f0
>
>The other strange thing is that the server receives a lot of requests to
>close the connection from the clients, for example:
>
>node0101:~ # bzcat /var/log/messages-20071013.bz2 | grep "close 1$"
>...
>Oct 12 18:07:15 node0101 kernel: svc: tcp_recv ffff810114f16dc0 data 1 
>conn 0 close 1
>Oct 12 18:07:54 node0101 kernel: svc: tcp_recv ffff810114e07c80 data 0 
>conn 0 close 1
>Oct 12 18:10:58 node0101 kernel: svc: tcp_recv ffff810114fcc880 data 1 
>conn 0 close 1
>Oct 12 18:11:54 node0101 kernel: svc: tcp_recv ffff81010e940a80 data 0 
>conn 0 close 1
>Oct 12 18:13:40 node0101 kernel: svc: tcp_recv ffff81013e4cd6c0 data 1 
>conn 0 close 1
>Oct 12 18:13:45 node0101 kernel: svc: tcp_recv ffff810111acd8c0 data 1 
>conn 0 close 1
>Oct 12 18:15:25 node0101 kernel: svc: tcp_recv ffff810112431c80 data 0 
>conn 0 close 1
>Oct 12 18:16:00 node0101 kernel: svc: tcp_recv ffff810114f58980 data 1 
>conn 0 close 1
>Oct 12 18:16:17 node0101 kernel: svc: tcp_recv ffff810114f58180 data 1 
>conn 0 close 1
>Oct 12 18:16:27 node0101 kernel: svc: tcp_recv ffff81011130cc80 data 1 
>conn 0 close 1
>Oct 12 18:16:37 node0101 kernel: svc: tcp_recv ffff81011130ca80 data 1 
>conn 0 close 1
>Oct 12 18:17:03 node0101 kernel: svc: tcp_recv ffff81011130c880 data 1 
>conn 0 close 1
>Oct 12 18:20:18 node0101 kernel: svc: tcp_recv ffff8100d67be9c0 data 1 
>conn 0 close 1
>Oct 12 18:22:52 node0101 kernel: svc: tcp_recv ffff810111a23bc0 data 0 
>conn 0 close 1
>...
>
>Is it an expected behaviour or a potential symptom of a problem? Which
>info could I search in the logs?
>
>Any help appreciated.
>
>Thanks,
>-Andrea

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
