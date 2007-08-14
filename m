From: Eli Stair <estair@ilm.com>
Subject: Re: Live performance tools?
Date: Tue, 14 Aug 2007 10:39:52 -0700
Message-ID: <46C1E8E8.3060405@ilm.com>
References: <slrnfc1j28.fcc.jgoerzen@katherina.lan.complete.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: John Goerzen <jgoerzen@complete.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IL0N3-0001zy-8l
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 10:39:57 -0700
Received: from gateway01.lucasfilm.com ([63.82.98.221])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IL0N6-0001K6-9V
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 10:40:01 -0700
In-Reply-To: <slrnfc1j28.fcc.jgoerzen@katherina.lan.complete.org>
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


Try lighting up an instance of ntop on the network you've got your NFS 
server(s) on.  Either span/mirror the switch ports so it sees all the 
traffic in promisc mode, or turn on sflow forwarding to the box.  As for 
determining what files are being accessed, you can use ethereal to 
capture traffic on the wire and analyze file ops occuring, but it's not 
fun to try and analyze #ops/file... you'd have to filter quite well, 
dump as XML/text and do some post-processing to generate your stats.

You could also start up inotify on the linux NFS server, watching the 
entire directory tree you're exporting via NFS, log the output, and 
later analyze the file ops as reported.  Maybe you should turn on some 
trending/monitoring of the clients themselves, I'd suggest ganglia for 
ease-of-deployment, but you could also use net-snmp and cacti, or 
monami... there are a number of ways to get data on traffic occuring at 
both ends of the transaction.

There's also an ncurses-based traffic tool that's sometimes handy for 
looking at NFS, but I don't recall its name offhand.


/eli

John Goerzen wrote:
> Hi,
> 
> We are deploying a number of Linux desktop clients running NFS against
> our Linux NFS server.  We are seeing occasional odd spikes in traffic
> that are causing performance troubles for all users.  We are trying to
> isolate the cause of these spikes, but to date haven't been able to.
> The best we can do is use iostat and verify that yes, the disk we
> expected is seeing a lot of traffic.
> 
> nfsd threads seem to be impervious to lsof.  top also doesn't show much
> about them, and of course you can't strace them.
> 
> Is there any tool out there that could give us any of this sort of info:
> 
>  * What IP addresses are generating high volumes of read or write
>    traffic
> 
>  * What files on disk are being accessed frequently via NFS
> 
>  * Anything else that could help us pinpoint the trouble
> 
> nfsstat does not seem to provide fine enough detail for this.
> 
> Thanks,
> 
> -- John
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
