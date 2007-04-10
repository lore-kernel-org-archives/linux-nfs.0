From: Olaf Kirch <okir@lst.de>
Subject: Re: lockd and statd
Date: Tue, 10 Apr 2007 10:47:39 +0200
Message-ID: <200704101047.40755.okir@lst.de>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
	<46142B4F.1030507@redhat.com>
	<1175728939.6459.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbC13-0006v5-JE
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 01:47:53 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbC14-0000Bw-JH
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 01:47:56 -0700
Received: from [192.168.5.32] (p54a7c470.dip.t-dialin.net [84.167.196.112])
	(authenticated bits=0)
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l3A8lxLD030152
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 10 Apr 2007 10:48:00 +0200
In-Reply-To: <1175728939.6459.9.camel@heimdal.trondhjem.org>
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

On Thursday 05 April 2007 01:22, Trond Myklebust wrote:
> Tom gave a talk on this subject at Connectathon last year. You can find
> his arguments for why statd DNS lookups are a must in his slides:
> 
>      http://www.connectathon.org/talks06/talpey-cthon06-nsm.pdf
> 
> Note his point that the server needs to store both the client hostname
> and IP address so that you can fail over from one to the other if the
> notification fails.

Well, I'm not really convinced. When monitoring a host, I think it is sufficient
to just store the mon_name; no IP address or anything. When dealing with an
incoming SM_NOTIFY, statd just needs to do a string match of the mon_name.
When sending out an SM_NOTIFY, we need a user space helper anyway,
which can do a full-blown DNS lookup and send notifications to *all* addresses
listed for each peer.

This is the approach I took with the kernel statd - these patches have been in 
Suse kernels for 1.5 years or so, and until I left in January, I hadn't seen a
single report that complained about lock reclaim problems.

Of course, clients need to send a mon_name that make sense from the
server's point of view in DNS - ie it must be a FQDN, or the server must be
able to find it via its resolv.conf search list.

I believe relying on the client's IP address will paper over configuration
problems at best, and lead to bad or incomplete notifications at worst.

A user space statd has its uses, eg with lock failover - but I believe the
majority of users is served by a small kernel statd just as well.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
