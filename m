From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: wiki.linux-nfs.org
Date: Tue, 28 Feb 2006 00:11:09 +0100
Message-ID: <200602280011.09331.bernd-schubert@gmx.de>
References: <200602251810.50744.bernd-schubert@gmx.de>
	<200602261454.51003.bernd-schubert@gmx.de>
	<44032127.1070008@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: cel@citi.umich.edu
In-Reply-To: <44032127.1070008@citi.umich.edu>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Monday 27 February 2006 16:56, Chuck Lever wrote:
> Bernd Schubert wrote:
> >>by adding the FAQ to the wiki, are you proposing that it should be
> >>removed from sourceforge, and maintained by whomever wants to edit the
> >
> > That was the idea, but thatswhy I also asked for objections.
>
> you posted your question at 9am (EST) on a non-workday, then you waited

Well, I'm working too much nowadays. Almost have forgotten that weekends ar=
e=20
non-workdays ;)

> less than an hour before proceeding with the transfer.  that's hardly
> "asking for objections."

Sorry, the initial transfer was more or less just a test how well it works=
=20
automatically.

>
> also, why didn't you contact me about this first?  i am the FAQ
> maintainer, after all.  is there a problem you are trying to address?
> is there something missing in the FAQ?  have i been slacking?

Sorry, clearly my fault. I was really unpolite, please excuse me.

>
> >>wiki pages?  i'm not really comfortable with that.  the FAQ is very very
> >>carefully crafted and vetted so that it contains good information.
> >
> > Well, thats the general problem of a wiki. Usually it works, but
> > sometimes there is vandalism. On the other hand, most pages of the NFSv4
> > stuff also can be edited by all.
> > Maybe we should add a page where people wanting to modify the wiki can
> > enter their username and email and Bryce can unlock them on request? (I
> > hope this is possible with mediawiki, we unlock per user with moinmoin).
>
> i think wikis are a great tool, but here's the problem.
>
> if anyone (in the NFS community) can edit the FAQ, what stops people
> from adding erroneous advice, or even advice that opens a security hole
> or that could cause silent data corruption?
>
> for example, what happens if someone comes along and sees the "async"
> export option on the server and says "oh wow!  i can make my server 10x
> faster with this!  i'm going to add something to the FAQ that encourages
> everyone to use the 'async' export option!"
>
> or even worse, someone adds advice to export shares without root
> squashing because it makes accessing the data "so much easier", or
> misconfigure Kerberos, and on and on.
>
> sure, you can back it out easily, because it's a wiki.  but this all
> depends on us knowing the NFS implementation well enough, testing the
> advice, and being on top of the changes so we can quickly remove advice
> that is destructive.
>
> basically, people trust that this information won't screw them.  if we
> let anyone edit this page, it will become worthless information.  you
> don't see the Linux kernel developed this way, and for exactly the same
> reasons.
>
> i don't deny that the FAQ and How-To could use some help.  but please,
> let's reasonably discuss why we want to do this first, and see if we can
> address those issues with what we have.

Actually, I just wanted to add a how-to about high-availibility, moving a n=
fs=20
exported partition and more details about the fsid usage.
I have now removed the transferred FAQ, but I'm still planning to add some =
ha=20
stuff there. It only too late now (midnight).

What do you think about naming the section in the Wiki 'User FAQ' and then =
to=20
put a big disclaimer on that page, that shortly explains that this is not t=
he=20
official howto?


Sorry again,
	Bernd

=2D-=20
Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
