From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 001 of 6] knfsd: Add a callback for when last rpc
	thread finishes.
Date: Tue, 4 Jul 2006 12:56:46 +0100
Message-ID: <20060704115646.GA2661@infradead.org>
References: <20060703161408.7009.patches@notabene> <1060703061911.7099@suse.de>
	<20060703221233.GA14273@infradead.org>
	<17577.47939.950315.755604@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxjWN-00058P-FX
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 04:56:51 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxjWM-0001Fo-GM
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 04:56:51 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17577.47939.950315.755604@cse.unsw.edu.au>
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

On Tue, Jul 04, 2006 at 10:50:11AM +1000, Neil Brown wrote:
> > Any chance you could convert all these svc threads to the kthread_
> > infrastructure before further complicating the already nasy interactions
> > it has with it's users?
> 
> Maybe .... could you remind me of the particular value of kthread_
> (other than general consistency which is obviously a good thing) to
> make sure I leverage it during the conversion.

 - it makes sure the threads are spawned by kevent so they are independent
   from the enviroment of the caller.  This is important for all the ongoin
   container work aswell as to avoid possible security issues.
 - it reduced complexity for thread creation and stopping a lot and thus
   eliminates various bugs crept in all over the place
(- we want to remove the kernel_thread export so people stop opencoding it
   in new code)

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
