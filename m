From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: RE:    1. NFS Performance issues... (Matt Heaton)
Date: Mon, 18 Mar 2002 10:58:15 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41C61615CE88D211AA3500805F9FFECE043C1165@renegade.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain
Received: from unogate.unocal.com ([192.94.3.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16n2L0-00066m-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Mar 2002 10:58:30 -0800
Received: from ns2.unocal.com (ns2.unocal.com [134.248.1.4])
	by unogate.unocal.com (8.11.6/8.11.6) with ESMTP id g2IIwRY21419
	for <nfs@lists.sourceforge.net>; Mon, 18 Mar 2002 10:58:27 -0800 (PST)
Received: from nimitz.unocal.com (localhost [127.0.0.1])
	by ns2.unocal.com (8.11.6/8.11.6) with ESMTP id g2IIwRh28157
	for <nfs@lists.sourceforge.net>; Mon, 18 Mar 2002 10:58:27 -0800 (PST)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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


	Matt,
	I have seen and read about a lot of problems with NFS/UDP
performance on heterogenous networks (gigabit ethernet <-> fast ethernet <->
ATM, etc.).
	We could not get our linux NFS clients to mount anything unless we
forced them into TCP mode.  With UDP there were so many retransmissions and
dropped packets that the clients appeared to hang when accessing anything
over NFS.  Our Sun boxes never had a problem because they use NFS over TCP
by default, and the Sun NFS servers can accept both TCP and UDP connections.
Once we forced TCP mode on the linux NFS clients they worked fine.

	IMHO it would be a good idea to apply the TCP patch to the NFS
server and force the clients to mount using TCP instead of UDP.  I'm betting
that it will help performance quite a bit.  Actually you might want to apply
Trond's patches to all of the NFS machines (client and server).  I'm using
them on production machines here with good results.  

	This doesn't explain why the data appears to 'stop' at 11Mbits, but
I think TCP will help your performance regardless.  In my testing on our
network I found that TCP mode was *always* faster than UDP regardless of
block size. 

	--aaron

	-----------

> Message: 1
> From: "Matt Heaton" <admin@0catch.com>
> To: <nfs@lists.sourceforge.net>
> Date: Fri, 15 Mar 2002 16:44:27 -0700
> Subject: [NFS] NFS Performance issues...
> 
> This is a multi-part message in MIME format.
> 
> ------=_NextPart_000_037F_01C1CC40.ABDAC8E0
> Content-Type: text/plain;
> 	charset="iso-8859-1"
> Content-Transfer-Encoding: quoted-printable
> 
> I run a fairly large free/paid hosting service.  We have about 8 =
> webservers (NFS Clients) that hook up to a single NFS server box.  We
> are having SEVERE performance issues.  The clients are READ ONLY =
> clients.  We have set the rsize to 8192 bytes, but otherwise
> are using the standard setup.  The NFS server seems to be able to only =
> serve about 11 Mbits of data before it dies?  Is this typical
> performace?  We are mostly serving web pages so most files are small =
> although some are bigger (3-5 megabytes).  Both the clients
> are the server are redhat 7.2  (NFS 3)
> 
> I AM LOOKING FOR SOME COMMERCIAL SUPPORT or some guru I can pay to help =
> with these issues.  PLEASE give me a call
> at (801) 361-1177 if you would be able to help.  We will pay for the =
> support we need.
> 
> Thanks,
> Matt Heaton
> 

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
