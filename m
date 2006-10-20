From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Regression: NFS locking hangs when statd not running.
Date: Fri, 20 Oct 2006 09:00:11 -0400
Message-ID: <76bd70e30610200600o2269db3ex2448982fb3e25d46@mail.gmail.com>
References: <17720.41873.549441.330938@cse.unsw.edu.au>
	<20061020124119.GE27351@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Takashi Iwai <tiwai@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gatz7-0001T5-TC
	for nfs@lists.sourceforge.net; Fri, 20 Oct 2006 06:00:28 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gatz7-0008MJ-K2
	for nfs@lists.sourceforge.net; Fri, 20 Oct 2006 06:00:27 -0700
Received: by nf-out-0910.google.com with SMTP id p46so1990462nfa
	for <nfs@lists.sourceforge.net>; Fri, 20 Oct 2006 06:00:13 -0700 (PDT)
To: "Neil Brown" <neilb@suse.de>, "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20061020124119.GE27351@suse.de>
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

On 10/20/06, Olaf Kirch <okir@suse.de> wrote:
> On Fri, Oct 20, 2006 at 08:23:13PM +1000, Neil Brown wrote:
> >  The problem is that there is a case where we don't want the retry.
> >
> >  In 2.6.18, if statd isn't running, then a lock attempt returns ENOLCK
> >  immediately, which I think is good.
> >  In 2.6.19-rc, in the same situation, a lock attempt waits for a major
> >  timeout (30 seconds for TCP mounts) and is not interruptible for this
> >  whole time (even with '-o intr' mounts).
> >
> >  So: what to do?  Should we retry requests when portmap says "no such
> >  service".
>
> When lockd tries to do an upcall to statd? Definitely no, I'd say.
> Essentially, statd upcalls should be a one-shot affair with minimal
> timeout.

I don't have a strong opinion here, but what you and Olaf say sounds reasonable.

> >  I think that for requests to a remote service - lockd or nfsd - we do
> >  want to retry.  The server might be rebooting and so "no such
> >  service" should be treated much like "no reply".
>
> I believe this should depend on the semantics of the parent mount.
> Basically, we should copy intr,hard from the NFS mount to the lockd
> client we use, and from there to the portmap client. Otherwise
> in a HA setup where you have hard mounts, you will suddenly start
> seeing IO errors during failover.

Copying the intr flag makes sense.  Neil, I'd like to see your patch
address this too.

The hard v. soft issue is more difficult.  The semantic you are
requesting for the local statd is clearly "soft" and that's what you
say you always want.  Otherwise copying the soft flag makes sense.

Maybe you can re-use the soft flag and expose a way to set the soft
timeout for the mon client to get the exact behavior you want?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
