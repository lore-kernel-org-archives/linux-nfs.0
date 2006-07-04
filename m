From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 001 of 6] knfsd: Add a callback for when last
	rpc	thread finishes.
Date: Tue, 4 Jul 2006 10:50:11 +1000
Message-ID: <17577.47939.950315.755604@cse.unsw.edu.au>
References: <20060703161408.7009.patches@notabene> <1060703061911.7099@suse.de>
	<20060703221233.GA14273@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxZ7k-0000nH-Rc
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 17:50:45 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxZ7j-0004XV-Lx
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 17:50:45 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: message from Christoph Hellwig on Monday July 3
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

On Monday July 3, hch@infradead.org wrote:
> On Mon, Jul 03, 2006 at 04:19:11PM +1000, NeilBrown wrote:
> > 
> > nfsd has some cleanup that it wants to do when the last thread
> > exits, and there will shortly be some more.
> > So collect this all into one place and define a callback for
> > an rpc service to call when the service is about to be destroyed.
> 
> Any chance you could convert all these svc threads to the kthread_
> infrastructure before further complicating the already nasy interactions
> it has with it's users?

Maybe .... could you remind me of the particular value of kthread_
(other than general consistency which is obviously a good thing) to
make sure I leverage it during the conversion.

Thanks,
NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
