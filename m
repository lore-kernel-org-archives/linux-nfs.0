From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 001 of 6] knfsd: Add a callback for when last rpc
	thread finishes.
Date: Mon, 3 Jul 2006 23:12:33 +0100
Message-ID: <20060703221233.GA14273@infradead.org>
References: <20060703161408.7009.patches@notabene> <1060703061911.7099@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxWem-0004WI-Rv
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 15:12:40 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxWek-0001nO-S0
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 15:12:41 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060703061911.7099@suse.de>
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

On Mon, Jul 03, 2006 at 04:19:11PM +1000, NeilBrown wrote:
> 
> nfsd has some cleanup that it wants to do when the last thread
> exits, and there will shortly be some more.
> So collect this all into one place and define a callback for
> an rpc service to call when the service is about to be destroyed.

Any chance you could convert all these svc threads to the kthread_
infrastructure before further complicating the already nasy interactions
it has with it's users?


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
