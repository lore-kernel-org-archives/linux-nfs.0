From: Scott McDermott <mcdermot@questra.com>
Subject: Re: current Trond NFS patch for 2.2.22?
Date: Mon, 7 Oct 2002 21:38:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021007213843.M26432@questra.com>
References: <20021007183704.K24367@questra.com> <shsfzvhsszs.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186] helo=questra.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yjKg-00053J-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 18:38:46 -0700
Received: (from mcdermot@localhost)
	by odio.roc.questra.com (8.11.6/8.11.4) id g981chx23639
	for nfs@lists.sourceforge.net; Mon, 7 Oct 2002 21:38:43 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <shsfzvhsszs.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Tue, Oct 08, 2002 at 01:56:39AM +0200
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Trond Myklebust on Tue  8/10 01:56 +0200:
> >>>>> " " == Scott McDermott <mcdermot@questra.com> writes:

what's this empty string? where does it get its value? my MUA set up
improperly or something?

>      > yes some of us are still using 2.2 if I use 2.2.22 + Trond's
>      > linux-2.2.21-NFS.dif am I current? It applies fine (minus a
>      > cast which was already included)
> 
> Hardly current, but definitely up to the limits of which I'm prepared
> to go with 2.2.x 8-)

biggest thing stopping me from upgrading the servers to 2.4 is knowing
that everyone will get stale handles, this will be very hard to manage
logistically, too many disparate political units with clients mounting
off it.  You said before that there is server code to handle old 2.2
cookies but I've heard otherwise from posts on the list and 2.2 works
too well for us right now to risk this.  I really should get around to
testing this though.  Truth is, 2.2 works well for our needs, I don't
really care to upgrade until we get something worthwhile like RPCSEC and
ACL support.

your patches affect client only though right?

Our servers are running 2.2.18pre19 with UDP rsize fix since forever,
with no problems whatever.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
