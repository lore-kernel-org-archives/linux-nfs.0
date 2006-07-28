From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: default sunrpc.min_resvport
Date: Fri, 28 Jul 2006 13:45:40 -0400
Message-ID: <76bd70e30607281045x36c1f54fvd1fade41f3186156@mail.gmail.com>
References: <Acax73tEH/h8g6AYSzKR6j1VBvcdsQAdEwfg>
	<168996D6C4DFA945B032B63C0DEAA6BF0421EA43@EXCHANGE1.postini.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6WPB-0004RW-BK
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:45:45 -0700
Received: from nf-out-0910.google.com ([64.233.182.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6WPB-0002ym-Bg
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:45:45 -0700
Received: by nf-out-0910.google.com with SMTP id m19so257383nfc
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 10:45:41 -0700 (PDT)
To: "Michael Han" <mhan@postini.com>
In-Reply-To: <168996D6C4DFA945B032B63C0DEAA6BF0421EA43@EXCHANGE1.postini.com>
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

On 7/28/06, Michael Han <mhan@postini.com> wrote:
> > From Chuck Lever:
> > Raising the minimum port number is one way to avoid port number
> > collisions.  However, you are chopping away a lot of usable ports when
> > you do this, something that some sites can't afford.  Especially if
> > you use automounter, or expect your clients to support more than a
> > couple hundred NFS mounts at once, you will probably need the expanded
> > port space.
>
> For my own peculiar requirements, a diminished number of privileged
> source ports is perfectly fine. I don't have hosts that mount a large
> number of shares, even though I do have an automount home in some cases
> (I just don't have enough users on my production systems to need this).

"For the record," some sites have a requirement for a larger port space.

> > A better way to eliminate the problem is to start a dummy daemon on
> > port 664 (or any other ports that the hardware might use
> > "transparently") so that the RPC client entirely avoids choosing those
> > port numbers.  I believe that some enterprise distributions (RHEL?  I
> > can't remember) have chosen to provide such daemons for just this
> > purpose.
>
> I saw that this was the suggested workaround from mailing list postings,
> but saw a reference to some kind of automount or mount bug that still
> ran afoul port 664 somehow. Anyway, a "fake" daemon would show up on
> security port scans and be one more thing to explain at audit time
> (paperwork avoidance is always a worthy goal in my view ;).

The daemon actually wouldn't show up on the security scan.  The
hardware IPMI listener would, however.  The daemon is not visible on
the network because the IPMI listener diverts packets to that port.

Other workarounds worth mentioning: disable IPMI in the hardware, or
don't use the built-in NIC for NFS traffic.

> I notice that some NFS implementations can accept client mounts from
> non-privileged source ports (>= 1024). I'm not sure what the security
> ramifications are (off the top of my head, that doesn't seem appropriate
> for anyone relying on host-based security), but for truly large NFS
> setups, perhaps this might be something to consider? Or perhaps a scheme
> for re-using source ports may be feasible (or even using a single
> connection to plex multiple mounts from the same host as you'd see with
> an auto-home setup?).

For AUTH_SYS, the privileged port is expected, as a guarantee that the
uid's passed in the requests are more or less trusted.  For AUTH_GSS,
non-privileged ports are just fine to use, as long as the server
supports it, and as long as dropping back to AUTH_SYS changes back to
a privileged port.

That's been considered, but is a low priority.

> Finally, fundamentally this seems to me a defect in the implmentation of
> IPMI BMCs. Shouldn't packets that cannot be processed by the BMC be
> passed to the standard kernel driver? Particularly for TCP, this seems
> like a good idea...

Indeed.  I'm not familiar enough with IPMI to know if it listens on
both the UDP and the TCP port.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
