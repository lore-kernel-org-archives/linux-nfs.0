From: marius aamodt eriksen <marius@umich.edu>
Subject: Re: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 02:23:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020815062332.GB9122@umich.edu>
References: <shs8z39dr15.fsf@charged.uio.no> <200208142234.g7EMYvQ21700@tooting-fe.eng>
Reply-To: marius@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, dax@gurulabs.com,
	torvalds@transmeta.com, kmsmith@umich.edu,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from citi.umich.edu ([141.211.92.141])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fE2g-0000en-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 23:23:34 -0700
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

* Brian Pawlowski <beepy@netapp.com> [020814 18:36]:
> > RPCSEC_GSS is not an argument for NFSv4...
> 
> yes.
> 
> But ACL support over the wire is an argument for V4 - and fine grained
> authorization coupled to strong authentication makes for a flexible 
> security package.

and let's not forget such things as getting rid of the representation
of users as UIDs over the wire, as well as delegations (i.e. better
caching == better performance), named (extended) attributes support,
soon-to-come interoperability with a vast array of operating systems,
etc. etc.

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
