From: "Matt Heaton" <admin@0catch.com>
Subject: Re: NFS Performance issues...
Date: Sat, 16 Mar 2002 09:54:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <040601c1cd0b$4f707930$2651a641@laptop>
References: <038201c1cc7b$5c8be400$2651a641@laptop> <20020316163451.A9226@stud.ntnu.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Received: from dns1.hawaiian.net ([12.36.97.1])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mHST-0003XF-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Mar 2002 08:55:05 -0800
Received: from laptop (ip12-36-108-34.dial.hawaiian.net [12.36.108.34])
	by dns1.hawaiian.net (8.11.6/8.11.6) with SMTP id g2GGtpl77983
	for <nfs@lists.sourceforge.net>; Sat, 16 Mar 2002 06:55:51 -1000 (HST)
	(envelope-from admin@0catch.com)
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Sorry, we have a 100 Mbit Network.  A cisco 2924 switch where everything =
is
plugged into.  An ALTEON Load balancer/firewall.  We are running 2.4.7-10
(Redhat 7.2).  I believe it might be something with the kernel as somethi=
ng
the
memory just spirals down.  Doesn't 7.2 have some virtual memory problem l=
ike
that?

Matt

----- Original Message -----
From: "Thomas Lang=E5s" <tlan@stud.ntnu.no>
To: "Matt Heaton" <admin@0catch.com>
Cc: <nfs@lists.sourceforge.net>
Sent: Saturday, March 16, 2002 8:34 AM
Subject: Re: [NFS] NFS Performance issues...


> Matt Heaton:
> > I run a fairly large free/paid hosting service.  We have about 8
webservers (NFS Clients) that hook up to a single NFS server box.  We
> > are having SEVERE performance issues.  The clients are READ ONLY
clients.  We have set the rsize to 8192 bytes, but otherwise
> > are using the standard setup.  The NFS server seems to be able to onl=
y
serve about 11 Mbits of data before it dies?  Is this typical
> > performace?  We are mostly serving web pages so most files are small
although some are bigger (3-5 megabytes).  Both the clients
> > are the server are redhat 7.2  (NFS 3)
>
> You fail to mention what kernel version you're running?
>
> --
> Thomas
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
