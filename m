From: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Subject: Re: .Xauthority going stale (but not really)
Date: Sat, 14 Jun 2008 17:25:21 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.0806141719200.2710@qygrfg01.brgvxre.pu>
References: <alpine.DEB.1.10.0806110849250.11896@qygrfg01.brgvxre.pu> <18512.26540.511674.417268@notabene.brown>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463765504-1403542719-1213457121=:2710"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from james.oetiker.ch ([213.144.138.195]:39960 "EHLO
	james.oetiker.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbYFNPZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Jun 2008 11:25:23 -0400
In-Reply-To: <18512.26540.511674.417268-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463765504-1403542719-1213457121=:2710
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hi Neil,

Thursday Neil Brown wrote:

> On Wednesday June 11, tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org wrote:
> > Experts,
> >
> > I have a strange problem on a diskless client. At ramdom intervals
> > (hours) when I try to open an xterm I get the message
> >
> >  > xterm
> >  No protocol specified
> >  xterm Xt error: Can't open display: :13.0
> >
> > Doing an strace on xterm I find that it gets a 'stale nfs handle'
> > when trying to open .Xauthority.
> >
> > If I do a
> >
> >  cat .Xauthority >/dev/null
> >
> > things go back to normal and I can open xterms again ...
> >
> > so how can it be, that xterm gets a stale nfs handle error while
> > cat can read the file just fine and after cat did it it works for
> > xterm as well ?
>
> xterm is setuid root.  cat is not.

right ...

> The filesystem is exported in a way the causes 'root' accesses to be
> treated as accessed by 'nobody'.  If the NFS server is Linux, then the
> export option "no_root_squash" can fix this.
>
> If the .Xauthority file is in cache on the client, xterm will be able
> to read it with no problem.  If not, it will send a request to the
> server for root to be able to read the file, and the server will
> reject the request.
>
> It should really return EACCES rather than ESTALE though ... what is
> the NFS server?

It is a linux 2.6.24.2 amd64 box ...

When the problem manifested it self again today I did an strace on
xterm (this does also have the effect that it does not run setuid
as fahr as I know, but the effect is the same).

 % strace xterm |& grep Xaut
 access("/home/oetiker/.Xauthority", R_OK) =3D -1 ESTALE (Stale NFS file ha=
ndle)

So it seems that xterm does not directly open the .Xauthority file,
but uses the access system call to check if it could open the file
if it was not running setuid (clever!).

From=20access(2):

  The check is done using the calling process's real UID and GID,
  rather than the effective IDs as is done when actually attempting
  an operation (e.g., open(2)) on the file.  This allows
  set-user-ID programs to easily determine the invoking user's
  authority.

cheers
tobi

> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

--=20
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten
http://it.oetiker.ch tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org ++41 62 213 9902
---1463765504-1403542719-1213457121=:2710--
