From: jp@pour.midcoast.com
Subject: Re: performance question
Date: Tue, 1 Apr 2003 10:39:50 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030401153950.27556.qmail@pour.midcoast.com>
References: <1049188686.19334.20.camel@deskpro02>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pour.midcoast.com ([206.26.226.21] ident=qmailr)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190NnJ-0000wf-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 07:35:25 -0800
To: ukh@id.cbs.dk (=?ISO-8859-1?Q?K=E5re?= Hviid)
In-Reply-To: <1049188686.19334.20.camel@deskpro02> from "=?ISO-8859-1?Q?K=E5re?= Hviid" at Apr 01, 2003 11:18:05 AM
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Thanks to the several people for responses!

> > Server (coffeepot) - Athlon XP2000, Suse 8.1, 2.4.21-pre6 kernel from
> > kernel.org, boots to an ata100 drive, promise rm8000 external hardware=20
> > raid5 array on adaptec Adaptec AHA-2940U/UW/D controller, 3com 3c905C=20
> > forced to 100-FD with "/sbin/mii-tool -F 100baseTx-FD eth1".
> 
> Fast question: Are you sure the _switch_ is setup to do
> 100FD as well?  In my experience, forcing FD on newer
> cards and switches is something that must be done
> carefully.  Also, what about link flow control?  I'm not
> sure the 3c905c can be forced to do flow control by
> simple means if your switch happens to support it.  Try
> the same using N-Way auto-negotiation and check what the
> 3c905c thinks about it.

Flow control on the switch is disabled - the default, I checked. It's also 
set for 100-FD, like my ethernet cards. I always hard-set ethernet 
settings because I don't trust autonegotiation under all circumstances.

I installed iperf on both machines and there is not a problem sending 
large amounts of data between machines.

coffeepot:~ # /usr/local/bin/iperf -s -u     

froth:/tmp/iperf-1.7.0 # /usr/local/bin/iperf -c 10.0.34.1 -b 100m
WARNING: option -b implies udp testing
------------------------------------------------------------
Client connecting to 10.0.34.1, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size: 64.0 KByte (default)
------------------------------------------------------------
[  5] local 10.0.34.2 port 32876 connected with 10.0.34.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec   114 MBytes  95.6 Mbits/sec
[  5] Server Report:
[  5]  0.0-10.0 sec   114 MBytes  95.6 Mbits/sec  0.246 ms    0/81337 (0%)
[  5] Sent 81337 datagrams

froth:/proc # /usr/local/bin/iperf -c 10.0.34.1 -b 90m
WARNING: option -b implies udp testing
------------------------------------------------------------
Client connecting to 10.0.34.1, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size: 64.0 KByte (default)
------------------------------------------------------------
[  5] local 10.0.34.2 port 32876 connected with 10.0.34.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec   108 MBytes  90.5 Mbits/sec
[  5] Server Report:
[  5]  0.0-10.0 sec   108 MBytes  90.5 Mbits/sec  0.000 ms    0/76925 (0%)
[  5] Sent 76925 datagrams


> 
> Cheers,
> --=20
> K=E5re Hviid   Sys Admin     ukh@id.cbs.dk    +45 3815 3075
> Institut for Datalingvistik, Handelsh=F8jskolen i K=F8benhavn
> 


-- 
/*
Jason Philbrook   |   Midcoast Internet Solutions - Internet Access,
    KB1IOJ        |  Hosting, and TCP-IP Networks for Midcoast Maine
 http://f64.nu/   |             http://www.midcoast.com/
*/


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
