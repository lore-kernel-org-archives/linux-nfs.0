From: "H . J . Lu" <hjl@lucon.org>
Subject: Re: Broken NFS client in RedHat skipjack-beta2?
Date: Mon, 8 Apr 2002 11:28:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020408112858.A31533@lucon.org>
References: <20020408101828.A30419@lucon.org> <shsk7ri2gtz.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16udt4-00032E-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 11:29:06 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsk7ri2gtz.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Mon, Apr 08, 2002 at 08:19:52PM +0200
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

On Mon, Apr 08, 2002 at 08:19:52PM +0200, Trond Myklebust wrote:
> >>>>> " " == hjl  <H> writes:
> 
>      > Has anyone seen the NFS client crash the NetApp NFS sever? See
>      > http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=62967
> 
> What patches have they put into the skipjack-beta?

It is linux-2.4.18 plus vairous Red Hat patches. The following patches

linux-2.4.16-sh-20011213.patch
linux-2.4.17-scheduler.patch
linux-2.4.17-selected-ac-bits.patch
linux-2.4.18-rh-aio-20020326.patch

touch fs/nfs/.


H.J.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
