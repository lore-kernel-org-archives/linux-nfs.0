From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: How to unlock a file if an NFSv3 client dies forever?
Date: Wed, 26 May 2004 12:22:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085588570.3763.24.camel@lade.trondhjem.org>
References: <4F28105F70F4324A8723F0C949088941C29A36@pa-exch5.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT1B6-0003XF-QE
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:22:52 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BT1B6-0007dx-8Q
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:22:52 -0700
To: Howie Xu <howie@vmware.com>
In-Reply-To: <4F28105F70F4324A8723F0C949088941C29A36@pa-exch5.vmware.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 on , 26/05/2004 klokka 04:03, skreiv Howie Xu:=20
> For example, if my linux NFS client holds a write lock on /home/howie/REA=
DME,
> then crashes and I reinstall the OS upon rebooting. Does that mean my NFS
> server will hold this lock on this file *forever*? The NFS locks are
> advisory, but my other NFS clients who speak NLM with the same NFS server
> will not be granted lock for a file no one else ever cares.:(

Here's a hack for how to do it.


On the client:

        Stop the rpc.statd service
        touch /var/lib/nfs/sm/<ip-address-of-my-server>
        then restart rpc.statd

Note that on some distributions, the path is /var/lib/nfs/statd/sm. It
may also be that your distribution runs rpc.statd as an unprivileged
user, in which case make sure that you chown the file
<ip-address-of-my-server> to that unprivileged user account.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
