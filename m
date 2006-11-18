From: Kostas Georgiou <k.georgiou@imperial.ac.uk>
Subject: Re: nfs-utils-1.0.10/linux 2.6.18 bug? unable to start nfsd;
	nfssvc "Address already in use"
Date: Sat, 18 Nov 2006 15:08:37 +0000
Message-ID: <20061118150837.GA22995@imperial.ac.uk>
References: <20061118104230.24911.qmail@web23307.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GlRoF-0003De-8p
	for nfs@lists.sourceforge.net; Sat, 18 Nov 2006 07:08:47 -0800
Received: from heppc218.hep.ph.ic.ac.uk ([155.198.211.218])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GlRoF-0007Tu-2m
	for nfs@lists.sourceforge.net; Sat, 18 Nov 2006 07:08:48 -0800
To: Ray <whatdoineed2do@yahoo.co.uk>
In-Reply-To: <20061118104230.24911.qmail@web23307.mail.ird.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sat, Nov 18, 2006 at 10:42:29AM +0000, Ray wrote:

> had the same problem again, and running 'netstat
> -anptu | grep :2049' as root tells me that the statd
> had stolen that port 
> 
> udp        0      0 0.0.0.0:2049            0.0.0.0:* 
>                          954/rpc.statd
> 
> i think this is to do with the manner in which FC2
> starts the nfs (and related services) -- the 'nfs'
> service starts nfsd/quotad/mountd whilst there is a
> seperate 'nfslock' service which starts lockd and it
> is this latter service which is started first.
> 
> i'll take a look at the scripts and re-order them.
> many thanks for the pointers

In recent versions of Fedora and RHEL you can use something
like this in /etc/sysconfig/nfs to binf to specific ports
 RQUOTAD_PORT=10866
 STATD_PORT=10867
 MOUNTD_PORT=10868
 LOCKD_TCPPORT=10869
 LOCKD_UDPPORT=10869
 STATD_OUTGOING_PORT=10870
and in /etc/modprobe.conf
 options lockd nlm_tcpport=10865 nlm_udpport=10865
 
It's mostly there for firewalls but it will solve your problems.

Cheers,
Kostas Georgiou

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
