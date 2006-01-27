From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Three ports required for nfs mounting?
Date: Fri, 27 Jan 2006 08:59:50 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0601270859400.4298@chaos.egr.duke.edu>
References: <1138334981.22516.8.camel@nietzsche>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2U8p-00046t-1I
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 05:59:55 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F2U8o-0007YD-Uo
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 05:59:55 -0800
To: Peter M Kekenes-Huskey <huskeypm@wag.caltech.edu>
In-Reply-To: <1138334981.22516.8.camel@nietzsche>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 26 Jan 2006 at 8:09pm, Peter M Kekenes-Huskey wrote

> I currently use guarddog/firestarter (on different machines) to
> configure my iptables.  When activated, although ports 111 and 2049 were
> freed for nfs, i was unable to mount shared volumes from a remote host.
> After scanning my tcpdump outputs, it came to my attention that an
> additional port (861 in this case) needed to be opened to allow
> mounting:
>
> < 10.1.1.2 is the remote computer, 10.1.1.3 is the nfs host>
>
> 19:55:09.466230 10.1.1.3.111 > 10.1.1.2.32798: F [tcp sum ok] 33:33(0)
> ack 62 win 5840 (DF) (ttl 64, id 9328, len 40)
> 19:55:09.466345 10.1.1.2.32798 > 10.1.1.3.111: . [tcp sum ok] 62:62(0)
> ack 34 win 5840 (DF) (ttl 64, id 64023, len 40)
> 19:55:12.465733 10.1.1.2.32799 > 10.1.1.3.861: S [tcp sum ok]
> 362674659:362674659(0) win 5840 <mss 1460> (DF) (ttl 64, id 49614, len
> 44)
> 19:55:20.621919 10.1.1.3.2406888837 > 10.1.1.2.2049: 104 getattr [|nfs]
> (DF) (ttl 64, id 5800, len 132)
>
> Once 861 was freed, all was well.  However, sharing different volumes
> requires freeing different ports, not just 861.  Does anyone understand
> why this happens?

http://nfs.sourceforge.net/nfs-howto/security.html#FIREWALLS

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
