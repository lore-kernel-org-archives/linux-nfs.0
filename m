From: "Michael Han" <mhan@postini.com>
Subject: Re: default sunrpc.min_resvport
Date: Fri, 28 Jul 2006 10:05:24 -0700
Message-ID: <168996D6C4DFA945B032B63C0DEAA6BF0421EA43@EXCHANGE1.postini.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6WDy-0003Ke-Aw
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:34:10 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1G6VmC-0004pU-Um
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:05:28 -0700
Received: from exprod8og55.obsmtp.com ([64.18.3.92])
	by mail.sourceforge.net with smtp (TLSv1:AES256-SHA:256) (Exim 4.44)
	id 1G6VmC-0001Pm-Dc
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:05:28 -0700
To: "Chuck Lever" <chucklever@gmail.com>
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

> From Chuck Lever:
> Raising the minimum port number is one way to avoid port number
> collisions.  However, you are chopping away a lot of usable ports when
> you do this, something that some sites can't afford.  Especially if
> you use automounter, or expect your clients to support more than a
> couple hundred NFS mounts at once, you will probably need the expanded
> port space.

For my own peculiar requirements, a diminished number of privileged
source ports is perfectly fine. I don't have hosts that mount a large
number of shares, even though I do have an automount home in some cases
(I just don't have enough users on my production systems to need this).
 
> A better way to eliminate the problem is to start a dummy daemon on
> port 664 (or any other ports that the hardware might use
> "transparently") so that the RPC client entirely avoids choosing those
> port numbers.  I believe that some enterprise distributions (RHEL?  I
> can't remember) have chosen to provide such daemons for just this
> purpose.

I saw that this was the suggested workaround from mailing list postings,
but saw a reference to some kind of automount or mount bug that still
ran afoul port 664 somehow. Anyway, a "fake" daemon would show up on
security port scans and be one more thing to explain at audit time
(paperwork avoidance is always a worthy goal in my view ;).

> In the meantime, we should consider raising the default minimum port
> number by 15 (or if we wanted to be particularly evil, we should chose
> 666 and be done with it).

That's why I suggested it. I'm not really sure adjusting port ranges is
a good generalized-case solution, but the loss of 15 (or 16 for the more
entertaining minimum value) usable ports doesn't seem likely to be
meaningful.

I notice that some NFS implementations can accept client mounts from
non-privileged source ports (>= 1024). I'm not sure what the security
ramifications are (off the top of my head, that doesn't seem appropriate
for anyone relying on host-based security), but for truly large NFS
setups, perhaps this might be something to consider? Or perhaps a scheme
for re-using source ports may be feasible (or even using a single
connection to plex multiple mounts from the same host as you'd see with
an auto-home setup?).

Finally, fundamentally this seems to me a defect in the implmentation of
IPMI BMCs. Shouldn't packets that cannot be processed by the BMC be
passed to the standard kernel driver? Particularly for TCP, this seems
like a good idea...

-- 
Michael Han






-----------------------------------------------------------
This message may contain confidential and/or privileged 
information. This information is intended to be read only
by the individual or entity to whom it is addressed. If
you are not the intended recipient, you are on notice that
any review, disclosure, copying, distribution or use of
the contents of this message is strictly prohibited. If
you have received this message in error, please notify the
sender immediately and delete or destroy any copy of this
message.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
