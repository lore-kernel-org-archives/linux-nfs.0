From: Mark Price <mkprice@us.ibm.com>
Subject: Re: wsize & PAGE_SIZE issues on IA64 clients.
Date: Mon, 31 Mar 2003 22:11:15 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.PTX.4.30.0303312210520.11440-100000@crg8.beaverton.ibm.com>
References: <shshe9izs2g.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mark Price <mkprice@us.ibm.com>,
   "Lever, Charles" <Charles.Lever@netapp.com>,
   Greg Lindahl <lindahl@keyresearch.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 190F05-0007NL-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 22:12:02 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shshe9izs2g.fsf@charged.uio.no>
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


Good point ;-) I hadn't thought of that. Its been one of those days!

Cheers, Mark.


On 1 Apr 2003, Trond Myklebust wrote:

> >>>>> " " == Mark Price <mkprice@us.ibm.com> writes:
>
>      > I'm currently getting my ia64 box rebuilt in order to an
>      > NFSSVC_MAXBLKSIZE of 64K. Anyone ever tried it?
>
> That won't work over UDP. The latter has a packet size that is limited
> to 64k, so you wouldn't have any space for the RPC header.
>
> For TCP it could work though...
>
> Cheers,
>   Trond
>



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
