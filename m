From: "David Shirley" <dave@cs.curtin.edu.au>
Subject: Re: KNFSD information  needed
Date: Sat, 3 May 2003 12:13:36 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001f01c3112a$5ef5c6d0$6e00a8c0@compaq3>
References: <002301c310aa$0ef33350$6e00a8c0@compaq3> <200305021626.42933.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-05.iinet.net.au ([203.59.3.37] helo=mail.iinet.net.au)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19BoYF-0000q7-00
	for <nfs@lists.sourceforge.net>; Fri, 02 May 2003 21:23:07 -0700
To: "Bernd Schubert" <bernd-schubert@web.de>,
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

Bernd,

This is why I am getting confused, because I have seen papers
comparing userspace nfsd with knfsd - performance and feature wise.

Also some people are making reference to a knfsd process which
i dont have, even though i have the appropriate options turned on
in the kernel.

Yes i have see the howto and there is no reference to knfsd, which
is why i am getting confused - perhaps the was once a knfsd but now it
is merged with the other nfsd?

Cheers
Dave

----- Original Message ----- 
From: "Bernd Schubert" <bernd-schubert@web.de>
To: "David Shirley" <dave@cs.curtin.edu.au>; <nfs@lists.sourceforge.net>
Sent: Friday, May 02, 2003 10:26 PM
Subject: Re: [NFS] KNFSD information needed


> On Friday 02 May 2003 14:55, David Shirley wrote:
> > Hi All,
> >
> > For a while now I was under the impression that nfsd provided with
Redhat
> > was the be all and end all, today after we had some fcntl locking issues
it
> > appears thats not the case.
> >
> > My first question is knfsd the same as the nfsd included in the
nfs-utils
> > package?
>
> Hmm, knfsd consists of 2 parts, the kernel nfsd-module and nfs-utils
rpc.nfsd.
> So the answer should be yes.
>
>  [snip]
>
> >
> > Sorry for these basic questions but the total lack of information online
> > is quite shocking.
>
> http://nfs.sourceforge.net/nfs-howto/
>
>
> >
> > Cheers
> > Dave
>
>
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
