From: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: NFS Performance issues...
Date: Sat, 16 Mar 2002 16:34:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020316163451.A9226@stud.ntnu.no>
References: <038201c1cc7b$5c8be400$2651a641@laptop>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from flaske.stud.ntnu.no ([129.241.56.72])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mGCt-0001zC-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Mar 2002 07:34:55 -0800
To: Matt Heaton <admin@0catch.com>
In-Reply-To: <038201c1cc7b$5c8be400$2651a641@laptop>; from admin@0catch.com on Fri, Mar 15, 2002 at 04:44:27PM -0700
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

Matt Heaton:
> I run a fairly large free/paid hosting service.  We have about 8 webservers (NFS Clients) that hook up to a single NFS server box.  We
> are having SEVERE performance issues.  The clients are READ ONLY clients.  We have set the rsize to 8192 bytes, but otherwise
> are using the standard setup.  The NFS server seems to be able to only serve about 11 Mbits of data before it dies?  Is this typical
> performace?  We are mostly serving web pages so most files are small although some are bigger (3-5 megabytes).  Both the clients
> are the server are redhat 7.2  (NFS 3)

You fail to mention what kernel version you're running?

-- 
Thomas

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
