From: marius aamodt eriksen <marius@umich.edu>
Subject: Re: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 02:18:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020815061848.GA9122@umich.edu>
References: <200208142234.g7EMYvQ21700@tooting-fe.eng> <1029373829.28240.16.camel@irongate.swansea.linux.org.uk>
Reply-To: marius@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Pawlowski <beepy@netapp.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>, dax@gurulabs.com,
	Linus Torvalds <torvalds@transmeta.com>, kmsmith@umich.edu,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from citi.umich.edu ([141.211.92.141])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fDy7-0008IY-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 23:18:51 -0700
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1029373829.28240.16.camel@irongate.swansea.linux.org.uk>
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

* Alan Cox <alan@lxorguk.ukuu.org.uk> [020814 21:13]:

> On Wed, 2002-08-14 at 23:34, Brian Pawlowski wrote:
> > But ACL support over the wire is an argument for V4 - and fine grained
> > authorization coupled to strong authentication makes for a flexible 
> > security package.
> 
> ACL works in NFSv2 and nicely in NFSv3 - again the problems Linux has
> are the client failing to respect basic NFS rules of operation.

there is no over-the-wire specification for sending or receving ACLs
on NFSv{2,3} - hence the server may choose to obey them, but an
arbitrary client cannot set them, or view them.

marius.

-- 
> marius@umich.edu > http://www.citi.umich.edu/u/marius


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
