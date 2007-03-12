From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: about quota implementation
Date: Mon, 12 Mar 2007 13:11:25 -0400
Message-ID: <1173719485.6436.35.camel@heimdal.trondhjem.org>
References: <1173715909.3889.23.camel@dhcp-107.ibrix.com>
	<20070312163517.GA8690@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQo3g-0008E2-VL
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:11:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+SVMDKZVZwfgZe5939X4FULOcy0/jHpN4=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQo3h-0006Ki-Fk
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:11:42 -0700
In-Reply-To: <20070312163517.GA8690@infradead.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-03-12 at 16:35 +0000, Christoph Hellwig wrote:
> On Mon, Mar 12, 2007 at 12:11:49PM -0400, Ming Zhang wrote:
> > Hi All
> > 
> > I have a question about current quota implementation. 
> > 
> > This is current implementation. There is a rquotad running on same box
> > as nfsd. Then in quota-tools, it check if file system type is nfs, then
> > it invoke a rpc call and get that from rquotad.
> > 
> > Another way is to implement the s_qcops in kernel nfs client and thus
> > quota-tools can use a unified way to get quotactl information.
> > 
> > Any special reason why not use 2nd way to make quota-tools simpler? One
> > reason I can think of is to put unnecessary code out of kernel. Is there
> > any other reason?
> 
> I think it's mostly a historical issue.  There was no abstraction
> between the quotactl syscall and the default disk based quota implementation
> at the time the nfs quote code was written.  I'd definitively welcome
> a patch adding a kernel interface for nfs quotas.

I wouldn't. 'NFS quotas' use a completely different RPC program. We do
not need to interface them to the VFS (the server will enforce quotas
without any client aid), and so the rquotad stuff really only exists in
order to allow users to display their quotas. It belongs in userland.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
