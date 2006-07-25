From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 11:36:37 -0400
Message-ID: <76bd70e30607250836v35110d6eo20043dccc4d284b7@mail.gmail.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<76bd70e30607250705h3e8c9eefjc794397e0c45a21b@mail.gmail.com>
	<D29213A6-C328-4C88-8D6D-428F3FDF4F56@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5Oxb-0007gs-Dn
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 08:36:39 -0700
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5Oxb-0004TJ-AS
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 08:36:39 -0700
Received: by nf-out-0910.google.com with SMTP id m19so257517nfc
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 08:36:37 -0700 (PDT)
To: "Paul Jimenez" <pj@rgmadvisors.com>
In-Reply-To: <D29213A6-C328-4C88-8D6D-428F3FDF4F56@rgmadvisors.com>
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

On 7/25/06, Paul Jimenez <pj@rgmadvisors.com> wrote:
>
> On Jul 25, 2006, at 9:05 AM, Chuck Lever wrote:
>
> > On 7/25/06, Neil Brown <neilb@suse.de> wrote:
> >> On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> >>> G'day,
> >>>
> >>>
> >>> 001 knfsd: move tempsock aging to timer
> >>
> >> Looks good.
> >> Has the subtle side effect that when we reach our limit on the number
> >> of permitted tcp connections, the one that is discarded is the one
> >> that has been open the longest, rather than the one that has be
> >> unused
> >> for the longest.  The comment there says
> >>                         /*
> >>                          * Always select the oldest socket. It's
> >> not fair,
> >>                          * but so is life
> >>                          */
> >> so I guess it is still correct ('oldest' is ambiguous).  The new
> >> situation is probably equally (un)fair - would you agree?
> >
> > Ouch.  IMO this will penalize long-running workloads unnecessarily,
> > and will likely be much more of a performance hit for such workloads
> > than would be gained by improving the CPU cache behavior on the
> > server.
> >
> > The previous algorithm (close the least recently used socket) is
> > more fair.
>
> OTOH, getting rid of the longest-open one may have beneficial side
> effects by restarting state associated with that long-running task from
> scratch, no?

What is being restarted is only the TCP connection.  Thus only network
layer state is being reconstructed here.

In addition, we have field evidence that breaking an active NFS/TCP
connection has lots of bad consequences.  The client is forced to
retransmit any RPC requests that were active when the connection was
dropped.  The client may reconnect on a different port number, which
makes the duplicate reply cache unable to prevent reapplying
non-idempotent RPC requests.  The combination invites data corruption
or application crashes due to unexpected return codes (but I though I
just created that file !?!).

My vote is to zap the least recently used connection.  That is overall
the safest compromise.

> Restarting long-running workloads with a clean slate every so often
> sounds like a good idea to me - I'm confident that the performance
> and impact of shorter lived connections is better understood than
> that of very long lived connections

By your logic, we should kill anyone who reaches the age of 30 so they
won't die of old age.

I'd rather find those lingering bugs and fix them, instead of cover
them up with a risky workaround.

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
