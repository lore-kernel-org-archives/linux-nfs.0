From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: gigabit, 2.4.22 and timeo
Date: Tue, 14 Oct 2003 12:26:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16268.9170.985048.378514@charged.uio.no>
References: <1066134271.629.19.camel@newdeal>
	<shs7k37x4rs.fsf@charged.uio.no>
	<1066148509.2582.1.camel@newdeal>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9S0o-0002Ow-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 09:27:06 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9S0n-00004z-GI
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 09:27:05 -0700
To: Roberto Sebastiano <robs@multiplayer.it>
In-Reply-To: <1066148509.2582.1.camel@newdeal>
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

>>>>> " " == Roberto Sebastiano <robs@multiplayer.it> writes:

     > Il mar, 2003-10-14 alle 16:39, Trond Myklebust ha scritto:
    >> > Is there any way to solve this ?
    >>
    >> There should be. Try applying patches number 02, 03 and 04 (in
    >> that order) from
    >>
    >> http://www.fys.uio.no/~trondmy/src/2.4.23-pre7

     > Great I'm transferring 120gb of data via net with those patches
     > applied and it runs just fine

     > Should I apply the others patches too for a production
     > environment ?

I would recommend that you at least apply

  linux-2.4.23-01-fix_deadlock.dif

and

  linux-2.4.23-05-fix_readdir.dif

in addition, since they fix critical problems (a deadlock and a stack
overflow).

The other patches are not critical (indeed some of them are
feature-enhancements) so you can probably drop them.

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
