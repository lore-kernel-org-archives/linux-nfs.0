From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: gigabit, 2.4.22 and timeo
Date: 14 Oct 2003 10:39:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs7k37x4rs.fsf@charged.uio.no>
References: <1066134271.629.19.camel@newdeal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9QL0-0000Oc-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 07:39:50 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9QKz-0007nu-Q4
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 07:39:50 -0700
To: Roberto Sebastiano <robs@multiplayer.it>
In-Reply-To: <1066134271.629.19.camel@newdeal>
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


     > Is there any way to solve this ?

There should be. Try applying patches number 02, 03 and 04 (in that
order) from

  http://www.fys.uio.no/~trondmy/src/2.4.23-pre7

Those patches have already been sent to Marcelo but haven't yet
appeared in his Bitkeeper tree...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
