From: Mark Price <mkprice@us.ibm.com>
Subject: RE: wsize & PAGE_SIZE issues on IA64 clients.
Date: Mon, 31 Mar 2003 15:46:45 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.PTX.4.30.0303311531280.11440-100000@crg8.beaverton.ibm.com>
References: <6440EA1A6AA1D5118C6900902745938E07D55484@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg Lindahl <lindahl@keyresearch.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 190904-00016Q-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 15:47:37 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D55484@black.eng.netapp.com>
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


I'm stil looking into how I can get reasonable performance from ia64 to
ia32 linux, with regards to maximum server block size of 8K. I found some
references to 64K blksize limit with V3 (I assume this meant what the
protocol definition will support - not what linux will support), and also
a 32K blocksize for TCP mounts.

http://www.linux.org/docs/ldp/howto/NFS-HOWTO/performance.html

I haven't played much with TCP mounts, how stable and how well do
they perform under linux?

I'm currently getting my ia64 box rebuilt in order to an NFSSVC_MAXBLKSIZE
of 64K. Anyone ever tried it?

Cheers, Mark.

On Mon, 31 Mar 2003, Lever, Charles wrote:

> > Is the "wsize < PAGE_SIZE" problem worth a printf in mount or
> > mountd or
> > the kernel?
>
> perhaps an entry in the NFS FAQ might be more timely, considering
> how long it would take this kind of change to make it into the
> common commercial distributions.
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: ValueWeb:
> Dedicated Hosting for just $79/mo with 500 GB of bandwidth!
> No other company gives more support or power for your dedicated server
> http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
