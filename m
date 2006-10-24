From: Neil Brown <neilb@suse.de>
Subject: Re: Regression: NFS locking hangs when statd not running.
Date: Tue, 24 Oct 2006 11:06:16 +1000
Message-ID: <17725.26376.280902.571606@cse.unsw.edu.au>
References: <17720.41873.549441.330938@cse.unsw.edu.au>
	<20061020124119.GE27351@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Takashi Iwai <tiwai@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcAkP-0000rJ-Sw
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 18:06:29 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcAkO-0005EC-CI
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 18:06:31 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Friday October 20
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

On Friday October 20, okir@suse.de wrote:
> 
> I believe this should depend on the semantics of the parent mount.
> Basically, we should copy intr,hard from the NFS mount to the lockd
> client we use, and from there to the portmap client. Otherwise
> in a HA setup where you have hard mounts, you will suddenly start
> seeing IO errors during failover.

Having almost implemented this, I find I disagree.  

Due to the state-management nature of lockd requests, I think they
need to be hard,nointr always (as they currently are) otherwise the
client and server can get out-of-sync causing serious confusion.

Normally I would expect a successful GETATTR before a lock request,
and the chance of the server becoming unavailable in that window is
pretty small.
'soft' lock requests are just silly, and interrupting lock requests
should be handled by leaving an unlock request running asynchronously
(which maybe we already do).

So I don't think there is anything that needs to be done specifically
to lockd requests.  statd is what I am really interested in here..


> 
> The patch looks good, except maybe I'd use a different name, like
> RPC_CLNT_BIND_NORETRY or some such.

Hmmm... you prefer the name to reflect what happens rather than why it
happens, and that is not unreasonable.  Your proposed name doesn't
quite capture what I was doing.  I was only avoiding the retry if
statd wasn't registered.  If portmap isn't running or statd is
responding slowly (or has died I guess) then we still retry.. Maybe we
shouldn't?

When talking to statd or local portmap we really want to abort if
statd says 'no', or if we get ECONREFUSED from portmap, and probably
even if we get ECONREFUSED from statd.... though I'm not 100% certain
about the last.
But if statd is slow, we still want to retry.

I think I'll stick with the current name, but the next patch will look
different and maybe we can discuss the name issue again...

Stay tuned.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
