From: Olaf Kirch <okir@suse.de>
Subject: Re: Regression: NFS locking hangs when statd not running.
Date: Fri, 20 Oct 2006 14:41:19 +0200
Message-ID: <20061020124119.GE27351@suse.de>
References: <17720.41873.549441.330938@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Takashi Iwai <tiwai@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gatgi-00084O-T5
	for nfs@lists.sourceforge.net; Fri, 20 Oct 2006 05:41:25 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gatgi-0006ZN-IO
	for nfs@lists.sourceforge.net; Fri, 20 Oct 2006 05:41:25 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17720.41873.549441.330938@cse.unsw.edu.au>
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

On Fri, Oct 20, 2006 at 08:23:13PM +1000, Neil Brown wrote:
>  The problem is that there is a case where we don't want the retry.
> 
>  In 2.6.18, if statd isn't running, then a lock attempt returns ENOLCK
>  immediately, which I think is good.
>  In 2.6.19-rc, in the same situation, a lock attempt waits for a major
>  timeout (30 seconds for TCP mounts) and is not interruptible for this
>  whole time (even with '-o intr' mounts).
> 
>  So: what to do?  Should we retry requests when portmap says "no such
>  service".

When lockd tries to do an upcall to statd? Definitely no, I'd say.
Essentially, statd upcalls should be a one-shot affair with minimal
timeout.

>  I think that for requests to a remote service - lockd or nfsd - we do
>  want to retry.  The server might be rebooting and so "no such
>  service" should be treated much like "no reply".

I believe this should depend on the semantics of the parent mount.
Basically, we should copy intr,hard from the NFS mount to the lockd
client we use, and from there to the portmap client. Otherwise
in a HA setup where you have hard mounts, you will suddenly start
seeing IO errors during failover.

The patch looks good, except maybe I'd use a different name, like
RPC_CLNT_BIND_NORETRY or some such.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
