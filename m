From: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Mon, 28 Feb 2005 04:32:14 +0100
Message-ID: <cvu2u9$k7a$1@sea.gmane.org>
References: <20050220111312.GA3974@s>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5bbQ-0002eS-1w
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 19:29:48 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D5bbO-0005HO-3X
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 19:29:47 -0800
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1D5bWr-0001ph-E1
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 04:25:05 +0100
Received: from dsl-082-082-126-054.arcor-ip.net ([82.82.126.54])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Mon, 28 Feb 2005 04:25:05 +0100
Received: from skoehler by dsl-082-082-126-054.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Mon, 28 Feb 2005 04:25:05 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20050220111312.GA3974@s>
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

> Why isn't it possible to specify all of statd's listening ports
> using the -p flag?  It works for the TCP port and one of the
> UDP ports, but there is always one more listening UDP port that
> is randomly assigned.  I googled around for information on this
> problem, and came up with this Debian bug report:
> 
>   http://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg11985.html
> 
> The thread ends with "I think we may have a real bug", but this
> was reported in 1.0.6, and the problem still persists in 1.0.7,
> so I was wondering if this isn't a bug after all.
> 
> Btw, there's also a similar problem with nfsd:  In addition to
> the standard listening port at 2049, it always opens a random
> port in the high port range (32000-32768 or something like that).
> 
> In case it matters:  I'm using Linux 2.6.10 and Slackware 10.1.

All that matters is "rpcinfo -p". As you can see, i managed to get 
everything on a specifig port:

# rpcinfo -p
    Program Vers Proto   Port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  30002  status
     100024    1   tcp  30002  status
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100021    1   udp  30004  nlockmgr
     100021    3   udp  30004  nlockmgr
     100021    4   udp  30004  nlockmgr
     100005    1   udp  30001  mountd
     100005    1   tcp  30001  mountd
     100005    2   udp  30001  mountd
     100005    2   tcp  30001  mountd
     100005    3   udp  30001  mountd
     100005    3   tcp  30001  mountd

You can ok any other port in your firewall.

You may want to have those two lines in your /etc/sysctl.conf:
   fs.nfs.nlm_udpport=30004
   fs.nfs.nlm_tcpport=30004

I still have problems with rquotad though. It doesn't to be possible to 
set that on a static port.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
