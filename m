From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fail to start rpc nfsd
Date: Sun, 12 Nov 2006 22:35:41 -0500
Message-ID: <1163388941.5736.8.camel@lade.trondhjem.org>
References: <20061113011342.22713.qmail@web35213.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjSc3-0004km-IG
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 19:35:59 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19ZELhcS2ycnpAgqtcCN1taE+XYTFafO1E=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjSc3-0004M8-Ca
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 19:36:00 -0800
To: Stephen Liu <satimis@yahoo.com>
In-Reply-To: <20061113011342.22713.qmail@web35213.mail.mud.yahoo.com>
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

On Mon, 2006-11-13 at 09:13 +0800, Stephen Liu wrote:
> Hi J. Bruce,
> 
> Tks for your advice.
> 
> > > $ ps -ef | egrep '/nfs-kernel-server'
> > > satimis   4841  4786  0 08:16 pts/2    00:00:00 grep -E
> > > /nfs-kernel-server
> > 
> > It's portmap you need to grep for.
> 
> $ ps -ef | egrep portmap
> daemon    3513     1  0 07:58 ?        00:00:00 /sbin/portmap -i
> 127.0.0.1
> satimis   4902  4786  0 09:01 pts/2    00:00:00 grep -E portmap
> * end *
> 
> It is there.

Check that you don't have an entry in /etc/hosts.deny that is blocking
access to portmap. Also check that you don't have any iptables entries
that are doing the same.

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
