From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Wed, 31 Jan 2007 00:42:43 +0100
Message-ID: <9a8748490701301542r33317ca7id9deb63fca2fb2dc@mail.gmail.com>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<17636.4462.975774.528003@cse.unsw.edu.au>
	<9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
	<17641.10665.116168.867041@cse.unsw.edu.au>
	<1156190098.6158.109.camel@localhost>
	<17853.33116.113629.65031@notabene.brown>
	<1170080210.5757.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HC2ch-0004oL-Ig
	for nfs@lists.sourceforge.net; Tue, 30 Jan 2007 15:42:47 -0800
Received: from wx-out-0506.google.com ([66.249.82.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HC2ce-0008CS-Gd
	for nfs@lists.sourceforge.net; Tue, 30 Jan 2007 15:42:49 -0800
Received: by wx-out-0506.google.com with SMTP id i30so52514wxd
	for <nfs@lists.sourceforge.net>; Tue, 30 Jan 2007 15:42:43 -0800 (PST)
In-Reply-To: <1170080210.5757.6.camel@lade.trondhjem.org>
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

On 29/01/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Mon, 2007-01-29 at 16:08 +1100, Neil Brown wrote:
> > On Monday August 21, trond.myklebust@fys.uio.no wrote:
> > >
> > > Could we instead replace it with a dprintk() that returns the value of
> > > "res"? That will keep it useful for debugging purposes.
> >
> > (only 5 months later...)
> >
> > Sure, how about this?
> >
> > Thanks,
> > NeilBrown
>
> ACKed.
>
> Thanks Neil!
>

Finally getting that in will be sooooo nice :-)  Thank you.

Btw: any reason why not to include the
  fl->fl_flags &= ~FL_SLEEP;
bit as well?  As in http://lkml.org/lkml/2006/11/27/41  ??


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
