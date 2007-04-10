From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: lockd and statd
Date: Tue, 10 Apr 2007 16:16:43 -0400
Message-ID: <EXNANE013ednHM3SOlb0000085c@exnane01.hq.netapp.com>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
	<46142B4F.1030507@redhat.com>
	<1175728939.6459.9.camel@heimdal.trondhjem.org>
	<200704101047.40755.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbMlX-0008F3-9W
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 13:16:35 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbMlY-00023H-Iu
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 13:16:37 -0700
In-Reply-To: <200704101047.40755.okir@lst.de>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
	<46142B4F.1030507@redhat.com>
	<1175728939.6459.9.camel@heimdal.trondhjem.org>
	<200704101047.40755.okir@lst.de>
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

At 04:47 AM 4/10/2007, Olaf Kirch wrote:
>This is the approach I took with the kernel statd - these patches have been in 
>Suse kernels for 1.5 years or so, and until I left in January, I hadn't seen a
>single report that complained about lock reclaim problems.

But, how would you know? Users have no clue what's going on, and
only some client machines make any attempt to tell them if the
reclaim doesn't succeed. Generally, their first indication is data
corruption.

Frankly, I was shocked when we investigated this behavior on
multiple systems, which is what motivated that Connectathon talk
I gave. Even when everything in the statd notifies worked, it was
easy to find situations where clients failed to reclaim.

>Of course, clients need to send a mon_name that make sense from the
>server's point of view in DNS - ie it must be a FQDN, or the server must be
>able to find it via its resolv.conf search list.
>
>I believe relying on the client's IP address will paper over configuration
>problems at best, and lead to bad or incomplete notifications at worst.

Yes, definitely a FQDN. Servers are not always in the same domain
as their clients. But the server must never rely on the source IP
either - it may change due to NAT, after a network partition, etc.
As I mentioned before, the client's hostname is the only invariant
in NLM recovery, such as it is. Belt-and-suspenders is the order of
the day, I'm afraid.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
