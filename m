From: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: NFS Performance issues...
Date: Sat, 16 Mar 2002 18:35:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020316183554.C9530@stud.ntnu.no>
References: <038201c1cc7b$5c8be400$2651a641@laptop> <20020316163451.A9226@stud.ntnu.no> <040601c1cd0b$4f707930$2651a641@laptop>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from brev.stud.ntnu.no ([129.241.56.70])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mI63-0004wQ-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Mar 2002 09:35:59 -0800
To: Matt Heaton <admin@0catch.com>
In-Reply-To: <040601c1cd0b$4f707930$2651a641@laptop>; from admin@0catch.com on Sat, Mar 16, 2002 at 09:54:53AM -0700
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
> Sorry, we have a 100 Mbit Network.  A cisco 2924 switch where everything is
> plugged into.  An ALTEON Load balancer/firewall.  We are running 2.4.7-10
> (Redhat 7.2).  I believe it might be something with the kernel as something
> the
> memory just spirals down.  Doesn't 7.2 have some virtual memory problem like
> that?

First off all, try updating to the errata kernel, 2.4.9  (it's in the
updates-directory on evey redhat-mirror).

-- 
Thomas

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
