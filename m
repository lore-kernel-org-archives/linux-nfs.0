From: Alexander Viro <viro@math.psu.edu>
Subject: Re: Re: Will NFSv4 be accepted?
Date: Wed, 14 Aug 2002 19:21:09 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <33037.5456520871$1029368022@news.gmane.org>
References: <200208142234.g7EMYvQ21700@tooting-fe.eng>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, dax@gurulabs.com,
        torvalds@transmeta.com, kmsmith@umich.edu,
        linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from leibniz.math.psu.edu ([146.186.130.2] helo=math.psu.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f7Rw-00008X-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 16:21:12 -0700
To: Brian Pawlowski <beepy@netapp.com>
In-Reply-To: <200208142234.g7EMYvQ21700@tooting-fe.eng>
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



On Wed, 14 Aug 2002, Brian Pawlowski wrote:

> > RPCSEC_GSS is not an argument for NFSv4...
> 
> yes.
> 
> But ACL support over the wire is an argument for V4 - and fine grained
> authorization coupled to strong authentication makes for a flexible 
> security package.

Not really.  With the quality of existing userland (Linux, Solaris, *BSD,
NT, etc.) _anything_ more complex than "I'm the only one who can create
or remove objects here" is a big, gaping hole.  Which makes any theoretical
benefits (if any) of ACL-based schemes moot.  Same (to slightly less extent)
applies to regular files.

In other words, if you need something more complex than usual - you are
screwed on the userland side, regardless of the kernel behaviour.



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
