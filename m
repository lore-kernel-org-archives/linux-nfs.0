From: Roberto Sebastiano <robs@multiplayer.it>
Subject: Re: gigabit, 2.4.22 and timeo
Date: Tue, 14 Oct 2003 19:02:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1066150954.2582.8.camel@newdeal>
References: <1066134271.629.19.camel@newdeal>
	 <shs7k37x4rs.fsf@charged.uio.no> <1066148509.2582.1.camel@newdeal>
	 <16268.9170.985048.378514@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9SZv-0005bu-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 10:03:23 -0700
Received: from vsmtp2.tin.it ([212.216.176.222] helo=vsmtp2alice.tin.it)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9SZv-0003py-0s
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 10:03:23 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16268.9170.985048.378514@charged.uio.no>
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

Il mar, 2003-10-14 alle 18:26, Trond Myklebust ha scritto:
> >>>>> " " == Roberto Sebastiano <robs@multiplayer.it> writes:
> 
>      > Il mar, 2003-10-14 alle 16:39, Trond Myklebust ha scritto:
>     >> > Is there any way to solve this ?
>     >>
>     >> There should be. Try applying patches number 02, 03 and 04 (in
>     >> that order) from
>     >>
>     >> http://www.fys.uio.no/~trondmy/src/2.4.23-pre7
> 
>      > Great I'm transferring 120gb of data via net with those patches
>      > applied and it runs just fine
> 
>      > Should I apply the others patches too for a production
>      > environment ?
> 
> I would recommend that you at least apply
> 
>   linux-2.4.23-01-fix_deadlock.dif
> 
> and
> 
>   linux-2.4.23-05-fix_readdir.dif
> 
> in addition, since they fix critical problems (a deadlock and a stack
> overflow).
> 
I'll apply them when the copy finishs

While transferring the files it seems that "ls -laR" on the other nfs
client is a little slow ..

I'm worried that the 500-1000 apache childs will hang on reads from
network. Is there any way to prevent this ? Maybe more nfsd instances on
the server ?



Thanks,
-- 
Roberto Sebastiano <robs@multiplayer.it>



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
