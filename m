From: "David Shirley" <dave@cs.curtin.edu.au>
Subject: Re: KNFSD information  needed
Date: Sat, 3 May 2003 23:13:54 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00c901c31186$9cc8efd0$6e00a8c0@compaq3>
References: <002301c310aa$0ef33350$6e00a8c0@compaq3> <200305021626.42933.bernd-schubert@web.de> <001f01c3112a$5ef5c6d0$6e00a8c0@compaq3> <200305031427.19693.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-02.iinet.net.au ([203.59.3.34] helo=mail.iinet.net.au)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Bym0-0000S2-00
	for <nfs@lists.sourceforge.net>; Sat, 03 May 2003 08:18:01 -0700
To: "Bernd Schubert" <bernd-schubert@web.de>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Bernd, Trond,

No not interesting in unfsd :)

Yes my nfsd shows up as [nfsd]. - i didn't occur to me that the "[]" meant
kernel :)

We have nfs working fine, but like i said reading some doco online
made reference to nfsd as well as knfsd. This doco is about 3 years old
however
so maybe the too have mereged since then.

In fact the html docs included in nfs-utils-0.3.3 package (redhat) make
reference
to a userspace and kernel space nfsd, with performance specs as well :)

I dont mean to put anyone down or anything, i think the nfs team are doing
a great job - i understand that its all volunteer work :)

I will read up on file locking - but this whole knfsd naming issue caught me
off guard :)

Cheers again
Dave

----- Original Message ----- 
From: "Bernd Schubert" <bernd-schubert@web.de>
To: "David Shirley" <dave@cs.curtin.edu.au>; <nfs@lists.sourceforge.net>
Sent: Saturday, May 03, 2003 8:27 PM
Subject: Re: [NFS] KNFSD information needed


> On Saturday 03 May 2003 06:13, David Shirley wrote:
> > Bernd,
> >
> > This is why I am getting confused, because I have seen papers
> > comparing userspace nfsd with knfsd - performance and feature wise.
>
> Why do you want to compare unfsd and knfsd ? Just believe me, unless you
have
> very special conditions, you won't want to try unfsd.
> Furthermore those papers should be rather outdated since except the
ClusterNFS
> users (we belong to them) nobody uses unfsd nowadays.
>
> >
> > Also some people are making reference to a knfsd process which
> > i dont have, even though i have the appropriate options turned on
> > in the kernel.
>
> Running 'ps ax' knfsd should appear like this:
>
>   637 ?        SW   569:03 [nfsd]
>
> Whereas unfsd (in our case ClusterNFS) would appear as:
>
>   522 ?        S     14:39 [rpc.nfsd.cnfs]
>
>
> Or are you the 'Debian User' who doesn't manage to get knfsd running ?
Without
> further information from his log-files nobody will we able to help him in
any
> case.
>
> >
> > Yes i have see the howto and there is no reference to knfsd, which
> > is why i am getting confused - perhaps the was once a knfsd but now it
> > is merged with the other nfsd?
>
> The hole howto is about knfsd ;)
>
>
> Bernd
>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
