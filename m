From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Tue, 18 Jan 2005 18:08:02 +0100
Message-ID: <200501181808.02576.vincent.roqueta@ext.bull.net>
References: <41E816B3.4030702@mitre.org> <1105747170.28849.22.camel@lade.trondhjem.org> <41ED233F.2070500@mitre.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1252"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CqwkY-0000z4-Ov
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 09:02:38 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CqwkV-0005mj-Tu
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 09:02:38 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 884AC19D906
	for <nfs@lists.sourceforge.net>; Tue, 18 Jan 2005 18:01:52 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 23163-03 for <nfs@lists.sourceforge.net>;
 Tue, 18 Jan 2005 18:01:50 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4E6D519D904
	for <nfs@lists.sourceforge.net>; Tue, 18 Jan 2005 18:01:50 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <41ED233F.2070500@mitre.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Le mardi 18 Janvier 2005 15:54, Jeff Blaine a =E9crit=A0:
> Trond Myklebust wrote:
> > fr den 14.01.2005 Klokka 14:00 (-0500) skreiv Jeff Blaine:
> >>Can anyone tell me what is happening in the graph at the URL
> >>below?  I can replicate it on any Linux box running 2.4.21
> >>and changing rsize/wsize doesn't affect it at all.  This
> >>was captured from a 2.6GHz P4 client machine.  Same thing
> >>is visible with a Dual 3GHz Xeon box with 4GB memory as a
> >>client.  A Solaris 9 client does not display this "falling
> >>on face" behavior.
> >>
> >>http://www.kickflop.net/temp/sol9-server-linux2421-client-gigE-ag930m_1=
05


That are reading perfs? Over a 1Gb/s network? Synchronous mount? (y)
Yours discs are capables of a 540Mo/s throughput? (No).
So you are working in cache...

http://nfsv4.bullopensource.org/tools/tests/NFSv4_tests.html


Vincent


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
