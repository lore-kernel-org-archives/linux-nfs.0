From: Roberto Sebastiano <robs@multiplayer.it>
Subject: Re: gigabit, 2.4.22 and timeo
Date: Tue, 14 Oct 2003 18:21:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1066148509.2582.1.camel@newdeal>
References: <1066134271.629.19.camel@newdeal>
	 <shs7k37x4rs.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9Rw4-0001fT-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 09:22:12 -0700
Received: from vsmtp2.tin.it ([212.216.176.222] helo=vsmtp2alice.tin.it)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9Rw3-0006rE-3C
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 09:22:11 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs7k37x4rs.fsf@charged.uio.no>
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

Il mar, 2003-10-14 alle 16:39, Trond Myklebust ha scritto:
>      > Is there any way to solve this ?
> 
> There should be. Try applying patches number 02, 03 and 04 (in that
> order) from
> 
>   http://www.fys.uio.no/~trondmy/src/2.4.23-pre7

Great
I'm transferring 120gb of data via net with those patches applied and it
runs just fine

Should I apply the others patches too for a production environment ?

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
