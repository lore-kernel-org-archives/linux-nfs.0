From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Re: Will NFSv4 be accepted?
Date: 15 Aug 2002 12:08:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1029409707.29812.7.camel@irongate.swansea.linux.org.uk>
References: <200208142234.g7EMYvQ21700@tooting-fe.eng>
	<1029373829.28240.16.camel@irongate.swansea.linux.org.uk>
	<20020815061848.GA9122@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brian Pawlowski <beepy@netapp.com>,
   Trond Myklebust
	 <trond.myklebust@fys.uio.no>, dax@gurulabs.com,
   Linus Torvalds
	 <torvalds@transmeta.com>, kmsmith@umich.edu,
   linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc2-cwma1-5-cust12.swa.cable.ntl.com ([80.5.121.12] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fIWC-0001YY-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 04:10:21 -0700
To: marius@citi.umich.edu
In-Reply-To: <20020815061848.GA9122@umich.edu>
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

On Thu, 2002-08-15 at 07:18, marius aamodt eriksen wrote:

> > ACL works in NFSv2 and nicely in NFSv3 - again the problems Linux has
> > are the client failing to respect basic NFS rules of operation.
> 
> there is no over-the-wire specification for sending or receving ACLs
> on NFSv{2,3} - hence the server may choose to obey them, but an
> arbitrary client cannot set them, or view them.

If you are trying to argue that NFSv4 handles ACL's better you are
preaching to the choir



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
