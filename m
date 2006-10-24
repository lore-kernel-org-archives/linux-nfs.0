From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Regression: NFS locking hangs when statd not running.
Date: Mon, 23 Oct 2006 18:53:59 -0700
Message-ID: <1161654839.6487.20.camel@lade.trondhjem.org>
References: <17720.41873.549441.330938@cse.unsw.edu.au>
	<20061020124119.GE27351@suse.de>
	<17725.26376.280902.571606@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Takashi Iwai <tiwai@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcBUj-0005Ig-9f
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 18:54:21 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcBUh-0003KW-Tr
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 18:54:22 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17725.26376.280902.571606@cse.unsw.edu.au>
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

On Tue, 2006-10-24 at 11:06 +1000, Neil Brown wrote:
> Due to the state-management nature of lockd requests, I think they
> need to be hard,nointr always (as they currently are) otherwise the
> client and server can get out-of-sync causing serious confusion.

Not really. As long as the interrupted lock request is followed by an
UNLOCK request, you should be safe.


> When talking to statd or local portmap we really want to abort if
> statd says 'no', or if we get ECONREFUSED from portmap, and probably
> even if we get ECONREFUSED from statd.... though I'm not 100% certain
> about the last.
> But if statd is slow, we still want to retry.

No. We should back off and retry. If the user wants to be able to lock,
then the kernel shouldn't be overriding that choice. Only if the user
specifies "nolock" should we fall back to local locking.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
