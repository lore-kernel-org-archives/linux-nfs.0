From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: wsize & PAGE_SIZE issues on IA64 clients.
Date: 28 Mar 2003 00:57:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr88sl5vs.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0303271219410.2496-100000@mprice-laptop.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yhFs-0004SA-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 15:57:56 -0800
To: Mark Price <mkprice@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0303271219410.2496-100000@mprice-laptop.beaverton.ibm.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Mark Price <mkprice@us.ibm.com> writes:

     > Can someone give me rough explanation of why that logic is
     > used? ie. Why the page is written synchronously if its smaller
     > than the page size? and Why even when its written synchronously
     > the wsize wasn't used, but the remote filesystems block size
     > was used?

  1) Because in order to write asynchronously you would have to have
     more than 1 outstanding request per page. The locking models all
     assume only 1 request / page.
  2) 'cos the servers get upset if we deliberately allow you to do
     things that violate the protocol.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
