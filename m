From: Jack Malmostoso <jackmalmostoso@freesurf.ch>
Subject: nfs does not work anymore after kernel panic
Date: Fri, 13 Feb 2004 20:47:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040213204735.6bafce1c@coppermine>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArjMB-0006eV-8H
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 11:52:11 -0800
Received: from freesurfmta07.sunrise.ch ([194.230.0.19] helo=freesurfmail.sunrise.ch)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1ArjKF-000380-1u
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 11:50:11 -0800
Received: from coppermine (62.167.36.198) by freesurfmail.sunrise.ch (7.0.024.3)
        id 400FC260003EBDBC for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 20:50:08 +0100
To: nfs@lists.sourceforge.net
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

Hi everybody,

I have set up a small LAN with this configuration:

Server: Fedora Core 1 machine, kernel 2.4.22, nfs-utils 1.0.6-1, connected to internet via a USB ADSL modem. Hostname is coppermine.

Client: Yellowdog 3.0.1 iBook, kernel 2.4.24, connected via eth0 to the server. Hostname is iBook.

/etc/exports is:

[jack@coppermine jack]$ cat /etc/exports
/mnt/share               iBook(rw,sync)

and rpcinfo says:

[root@coppermine root]# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32916  status
    100024    1   tcp  35327  status
    100011    1   udp    744  rquotad
    100011    2   udp    744  rquotad
    100011    1   tcp    747  rquotad
    100011    2   tcp    747  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32948  nlockmgr
    100021    3   udp  32948  nlockmgr
    100021    4   udp  32948  nlockmgr
    100021    1   tcp  36967  nlockmgr
    100021    3   tcp  36967  nlockmgr
    100021    4   tcp  36967  nlockmgr
    100005    1   udp    764  mountd
    100005    1   tcp    767  mountd

Now, everything was correctly working for a while, then I was downloading a file on the client from the server, and the server had a kernel panic with flashing lights and everything.
Since that, I have tried to setup again the network, but when I check with

[root@coppermine root]# showmount -e

if everything is ok, the shell just sits there with no output and no CPU consumption or anything.

In the meanwhile my iBook can surf the internet sharing the connection with coppermine, and the network itself is setup correctly, since the two machines ping each other without problems.

Now, do you have any help to give me? Thank you in advance!

-- 
Leela: "Great. We're two days from earth with no food."                                                                           
Bender: "Problem solved. You two fight to the death and I'll cook the
loser."                                                     


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
