From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how experimental is the seekdir patch
Date: 03 May 2003 21:47:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy91n4xti.fsf@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D55592@black.eng.netapp.com>
	<20030503182436.GA1613@nyongwa.montreal.qc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19C2yy-0002g3-00
	for <nfs@lists.sourceforge.net>; Sat, 03 May 2003 12:47:41 -0700
To: "Steve M. Robbins" <steven.robbins@videotron.ca>
In-Reply-To: <20030503182436.GA1613@nyongwa.montreal.qc.ca>
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

>>>>> " " == Steve M Robbins <steven.robbins@videotron.ca> writes:

     > Supposing the glibc got fixed.  Would the seekdir patch cause a
     > problem?  Is there no way that a similar kernel patch could
     > coexist with a fixed glibc?

That depends entirely on how glibc were to be fixed. If they simply
decided to make readdir cookies unsigned (as they were before) then
the answer is 'no'.
If, OTOH, they decide to eliminate their cookie 'sanity checking'
(hah!) code then a fix could indeed be made to coexist.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
