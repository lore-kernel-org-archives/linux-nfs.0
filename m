From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd and statd
Date: Tue, 10 Apr 2007 15:36:19 -0400
Message-ID: <1176233779.309.32.camel@heimdal.trondhjem.org>
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
	id 1HbM8o-0003va-Ki
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 12:36:34 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19VeRP42p5cuLa6G0DeJTbVyGQhEDwFi60=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbM8p-0005qF-Nd
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 12:36:37 -0700
In-Reply-To: <200704101047.40755.okir@lst.de>
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

On Tue, 2007-04-10 at 10:47 +0200, Olaf Kirch wrote:
> On Thursday 05 April 2007 01:22, Trond Myklebust wrote:
> > Tom gave a talk on this subject at Connectathon last year. You can find
> > his arguments for why statd DNS lookups are a must in his slides:
> > 
> >      http://www.connectathon.org/talks06/talpey-cthon06-nsm.pdf
> > 
> > Note his point that the server needs to store both the client hostname
> > and IP address so that you can fail over from one to the other if the
> > notification fails.
> 
> Well, I'm not really convinced. When monitoring a host, I think it is sufficient
> to just store the mon_name; no IP address or anything. When dealing with an
> incoming SM_NOTIFY, statd just needs to do a string match of the mon_name.
> When sending out an SM_NOTIFY, we need a user space helper anyway,
> which can do a full-blown DNS lookup and send notifications to *all* addresses
> listed for each peer.

What about peers that don't have a DNS entry? I certainly don't expect
all machines on my private LAN to have DNS entries.

> This is the approach I took with the kernel statd - these patches have been in 
> Suse kernels for 1.5 years or so, and until I left in January, I hadn't seen a
> single report that complained about lock reclaim problems.

History shows that a lack of complaints is not necessarily a good
measure of lack of problems. :-)

> Of course, clients need to send a mon_name that make sense from the
> server's point of view in DNS - ie it must be a FQDN, or the server must be
> able to find it via its resolv.conf search list.

> I believe relying on the client's IP address will paper over configuration
> problems at best, and lead to bad or incomplete notifications at worst.

You missed the point. The IP address was proposed as a _backup_ in case
the DNS lookup fails.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
