From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: wsize & PAGE_SIZE issues on IA64 clients.
Date: 01 Apr 2003 07:48:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshe9izs2g.fsf@charged.uio.no>
References: <Pine.PTX.4.30.0303311531280.11440-100000@crg8.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	  Greg Lindahl <lindahl@keyresearch.com>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190EdR-00046G-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 21:48:38 -0800
To: Mark Price <mkprice@us.ibm.com>
In-Reply-To: <Pine.PTX.4.30.0303311531280.11440-100000@crg8.beaverton.ibm.com>
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

     > I'm currently getting my ia64 box rebuilt in order to an
     > NFSSVC_MAXBLKSIZE of 64K. Anyone ever tried it?

That won't work over UDP. The latter has a packet size that is limited
to 64k, so you wouldn't have any space for the RPC header.

For TCP it could work though...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
