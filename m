From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: NFS related BUGs at shutdown - do_exit() + lock held at
	task exit time - 2.6.17.8
Date: Fri, 8 Dec 2006 21:02:40 +0100
Message-ID: <9a8748490612081202n752529c1x84afacb07547e767@mail.gmail.com>
References: <9a8748490612080341j4f0fa7b5l2f7272df0df55073@mail.gmail.com>
	<1165601022.5676.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gslvd-0007i3-F1
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 12:02:41 -0800
Received: from wx-out-0506.google.com ([66.249.82.238])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gslvd-0007o5-Ce
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 12:02:42 -0800
Received: by wx-out-0506.google.com with SMTP id i30so1455895wxd
	for <nfs@lists.sourceforge.net>; Fri, 08 Dec 2006 12:02:40 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1165601022.5676.22.camel@lade.trondhjem.org>
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

On 08/12/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Fri, 2006-12-08 at 12:41 +0100, Jesper Juhl wrote:
> > Greetings,
> >
> > I just got a kernel crash when shutting down a webserver. Nothing made
> > it to the logs, but I managed to get a photo of the dump on screen :
> > http://www.kernel.org/pub/linux/kernel/people/juhl/images/2.6.17.8-kernel-crash.jpg
>
> It is hard to see what is going on there. AFAICS, the more interesting
> stuff to do with the Oops itself has scrolled off the screen. Any chance
> it may have been syslogged?
>
Unfortunately no - I checked. All I have is that photo :-(

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
