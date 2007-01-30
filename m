From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: rpc.gssd segfault on FC5 client
Date: Mon, 29 Jan 2007 19:02:37 -0500
Message-ID: <4d569c330701291602l2baf90f4m4869c8402617f48a@mail.gmail.com>
References: <1169911208.2767.15.camel@localhost.localdomain>
	<20070129010419.GF12125@fieldses.org>
	<1170079837.2871.15.camel@localhost.localdomain>
	<45BE5A87.3010204@CS.Arizona.EDU>
	<4d569c330701291402pa6760c4mf64cbfd82cfc6fd2@mail.gmail.com>
	<45BE6FF9.6000101@CS.Arizona.EDU>
	<4d569c330701291444n36e3a891t318bcfe192c75a04@mail.gmail.com>
	<45BE7A11.1060706@CS.Arizona.EDU>
	<4d569c330701291518q5ece6beeoebff95c2ba44c3b7@mail.gmail.com>
	<45BE848B.2030907@CS.Arizona.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jim Davis" <jdavis@cs.arizona.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBgSM-0006vo-9R
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 16:02:38 -0800
Received: from wr-out-0506.google.com ([64.233.184.230])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBgSM-0005vs-TS
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 16:02:40 -0800
Received: by wr-out-0506.google.com with SMTP id i23so1076949wra
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 16:02:38 -0800 (PST)
In-Reply-To: <45BE848B.2030907@CS.Arizona.EDU>
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

On 1/29/07, Jim Davis <jdavis@cs.arizona.edu> wrote:
> Kevin Coffman wrote:
> > On 1/29/07, Jim Davis <jdavis@cs.arizona.edu> wrote:
> >> Kevin Coffman wrote:
> >> > I'm not seeing nfs-utils-debuginfo available.  What is included with
> >> > nfs-utils-debuginfo-1.0.8.rc2-4.FC5.2 ?
> >>
> >> Oh, right, I downloaded that rpm to another system and tarred the
> >> contents across to this one.  (That system had the same problem but I
> >> decided to focus on just this one.)  The rpm is supposed to have
> >> debuggable versions of the nfs-utils in it:
> >
> > So it looks like running /usr/lib/debug/usr/sbin/rpc.gssd.debug might
> > give us a backtrace to work with?
>
> Well, I'm not really clear on how the debuginfo stuff is supposed to be
> used, but it doesn't seem that I can run that file directly.  The best I
> could come up with after googling around is that it's meant to fed to
> gdb to analyze core dumps from the real executable.  But it's quite
> possible I'm missing something there...
>
> sh-3.1# ls -l /usr/lib/debug/usr/sbin/rpc.gssd.debug
> -rwxr-xr-x 1 root root 60564 Feb 12  2006
> /usr/lib/debug/usr/sbin/rpc.gssd.debug
> sh-3.1# /usr/lib/debug/usr/sbin/rpc.gssd.debug -f
> sh: /usr/lib/debug/usr/sbin/rpc.gssd.debug: Permission denied

I'll see if I can find that rpm and figure out how to make use of it...

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
