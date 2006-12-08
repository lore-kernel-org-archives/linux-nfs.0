From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: Let's get rid of those annoying "VFS is out of sync with
	lock manager" messages (includes proposed patch)
Date: Fri, 8 Dec 2006 15:48:24 +0100
Message-ID: <9a8748490612080648l427000a7ue613d8b124cc628e@mail.gmail.com>
References: <200612072208.16350.jesper.juhl@gmail.com>
	<17784.56763.794504.185193@cse.unsw.edu.au>
	<9a8748490612080635o3432d410gbb147c977de21499@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gsh1T-0006XK-U8
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 06:48:23 -0800
Received: from wr-out-0506.google.com ([64.233.184.232])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gsh1U-0007Pr-Vp
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 06:48:25 -0800
Received: by wr-out-0506.google.com with SMTP id i20so528407wra
	for <nfs@lists.sourceforge.net>; Fri, 08 Dec 2006 06:48:24 -0800 (PST)
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <9a8748490612080635o3432d410gbb147c977de21499@mail.gmail.com>
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

On 08/12/06, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> On 08/12/06, Neil Brown <neilb@suse.de> wrote:
> > On Thursday December 7, jesper.juhl@gmail.com wrote:
> > >
> > > So I took Neils patch, made the change Trond suggested and the result is
> > > below.
> > >
> > > Comments?  Ok to merge?
> >
> > Yes, except that you need a changelog comment at the top.  Possibly
> > based very heavily on the text I wrote, but written to justify the
> > patch rather than to explain the bug.
> >
> > NeilBrown
> >
>
> How about this for a changelog entry?  :
>
> Convert "VFS is out of sync with lock manager!" printk in
> do_vfs_lock() to dprintk() since the message is useless in normal use
> but could possibly be useful as a debugging aid.
> Also turn off FL_SLEEP when calling do_vfs_lock() just in case after
> getting -EINTR or -ERESTARTSYS.
>
>
Ohh and btw, I forgot to mention that the patch has been tested and
resolves my original issue.

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
