From: Neil Brown <neilb@suse.de>
Subject: Re: Regression: NFS locking hangs when statd not running.
Date: Tue, 24 Oct 2006 12:17:02 +1000
Message-ID: <17725.30622.629579.910456@cse.unsw.edu.au>
References: <17720.41873.549441.330938@cse.unsw.edu.au>
	<20061020124119.GE27351@suse.de>
	<17725.26376.280902.571606@cse.unsw.edu.au>
	<1161654839.6487.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Takashi Iwai <tiwai@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcBqv-0007Tt-Qf
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:17:17 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcBqs-00082M-Gm
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:17:18 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Monday October 23
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

On Monday October 23, trond.myklebust@fys.uio.no wrote:
> On Tue, 2006-10-24 at 11:06 +1000, Neil Brown wrote:
> > Due to the state-management nature of lockd requests, I think they
> > need to be hard,nointr always (as they currently are) otherwise the
> > client and server can get out-of-sync causing serious confusion.
> 
> Not really. As long as the interrupted lock request is followed by an
> UNLOCK request, you should be safe.

Yes, I guess so.  Do we do that?  Send an UNLOCK if a LOCK fails
mysteriously?

> 
> 
> > When talking to statd or local portmap we really want to abort if
> > statd says 'no', or if we get ECONREFUSED from portmap, and probably
> > even if we get ECONREFUSED from statd.... though I'm not 100% certain
> > about the last.
> > But if statd is slow, we still want to retry.
> 
> No. We should back off and retry. If the user wants to be able to lock,
> then the kernel shouldn't be overriding that choice. Only if the user
> specifies "nolock" should we fall back to local locking.

Certainly we should only fall back to lock locking if 'nolock' was
given.  But in what circumstances can we return -ENOLOCK?
I'm suggesting that if statd isn't running, then the best thing is to
return -ENOLOCK quickly.  Currently we block uninterruptible for 30
seconds (on a tcp mount).  For every lock request.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
