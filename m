From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: linux-2.4.19-18-noac.dif
Date: Wed, 27 Nov 2002 04:14:45 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15844.14501.89383.722832@charged.uio.no>
References: <OF97708985.A1869F34-ON88256C7E.000C7D0A@us.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles.Lever@netapp.com,
    NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: <OF97708985.A1869F34-ON88256C7E.000C7D0A@us.ibm.com>
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

>>>>> " " == Bruce Allan <bruce.allan@us.ibm.com> writes:

     > Hi Trond/Chuck,

     > I was looking through Trond's patch repository and saw the
     > patch listed above.  What was the problem, or potential
     > problem, that lead to this patch?  What would/could happen if a
     > page was not set up to date when an entire page gets written by
     > nfs_writepage_sync()?  I couldn't find any discussion of this
     > in the archives other than the posting of the patch to the nfs
     > list.

     > http://www.fys.uio.no/~trondmy/src/2.4.19/linux-2.4.19-18-noac.dif

That is an optimization. If you know that you have written the entire
page, then you want to mark it as being up to date. If not, then the
VFS will end up scheduling a readpage() the next time someone tries to
read from that particular page.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
