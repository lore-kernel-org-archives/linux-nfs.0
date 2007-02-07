From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] knfsd: Fix a race in closing NFSd connections.
Date: Tue, 6 Feb 2007 17:51:52 -0800
Message-ID: <20070206175152.39d767dd.akpm@linux-foundation.org>
References: <20070207110636.9166.patches@notabene> <1070207001026.9413@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, stable@kernel.org,
	linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HEbzh-00078a-At
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 17:53:09 -0800
Received: from smtp.osdl.org ([65.172.181.24])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1HEbzh-0000w9-4Y
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 17:53:09 -0800
In-Reply-To: <1070207001026.9413@suse.de>
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

On Wed, 7 Feb 2007 11:10:26 +1100
NeilBrown <neilb@suse.de> wrote:

> If you lose this race, it can iput a socket inode twice and you
> get a BUG in fs/inode.c
> 
> When I added the option for user-space to close a socket,
> I added some cruft to svc_delete_socket so that I could call
> that function when closing a socket per user-space request.
> 
> This was the wrong thing to do.  I should have just set SK_CLOSE
> and let normal mechanisms do the work.
> 
> Not only wrong, but buggy.  The locking is all wrong and it openned
> up a race where-by a socket could be closed twice.
> 
> So this patch:
>   Introduces svc_close_socket which sets SK_CLOSE then either leave
>   the close up to a thread, or calls svc_delete_socket if it can
>   get SK_BUSY.
> 
>   Adds a bias to sk_busy which is removed when SK_DEAD is set,
>   This avoid races around shutting down the socket.
> 
>   Changes several 'spin_lock' to 'spin_lock_bh' where the _bh 
>   was missing.
> 

This patch assumes the presence of
knfsd-sunrpc-allow-creating-an-rpc-service-without-registering-with-portmapper.patch which
obviously isn't appropriate for -stable.

Please confirm that the patch which I merged is still OK, thanks.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
