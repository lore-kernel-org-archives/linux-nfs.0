From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@lysator.liu.se>
Subject: Re: Re: NFS retry on disconnection
Date: Tue, 14 May 2002 08:37:29 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0205140833140.20950-100000@sofie.lambo.student.liu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a88.lambo.student.liu.se ([130.236.229.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177VwD-0005Mu-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 23:37:33 -0700
Received: from localhost (localhost [127.0.0.1])
	by a88.lambo.student.liu.se (Postfix) with ESMTP id 7C0EFCF3E
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 08:37:29 +0200 (CEST)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


>Linux NFS isn't any different from any other OS in this treatment of
>"soft" and "hard", although I guess an OS could have a default to
>"soft", which would be a bad idea.
>
>"Best practices" is to mount "hard,intr" so the user can interrupt the
>process if they wish to... otherwise it will wait until the problem is
>fixed. You should also use automounts to ensure that a minimum number

One thing that keeps annoying me is that "intr" only allows interrupting
the file operation when a major timeout happens. I want to be able to
interrupt at any time (as far as I know, Solaris works like this). Any
good reasons for only interrupting at major timeouts?

-- 
/Peter Åstrand <astrand@lysator.liu.se>




_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
