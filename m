From: Daniel Ellard <ellard@eecs.harvard.edu>
Subject: Re: NFS digest, Vol 1 #1848 - 6 msgs
Date: Mon, 10 May 2004 00:05:00 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040509235449.K15474@bowser.eecs.harvard.edu>
References: <E1BN1JU-0003Yo-He@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BN22N-00013k-91
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 21:05:07 -0700
Received: from bowser.eecs.harvard.edu
	([140.247.60.24] helo=mail.eecs.harvard.edu ident=postfix)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BN22M-0004PM-UZ
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 21:05:07 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail.eecs.harvard.edu (Postfix) with ESMTP id DC6B054C453
	for <nfs@lists.sourceforge.net>; Mon, 10 May 2004 00:05:00 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <E1BN1JU-0003Yo-He@sc8-sf-list2.sourceforge.net>
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

On Sun, 9 May 2004 nfs-request@lists.sourceforge.net wrote:

> Subject: Re: [NFS] Converting open filehandles to pathnames
> From: seth vidal <skvidal@phy.duke.edu>
> To: Erik Walthinsen <omega@pdxcolo.net>
> Cc: Greg Banks <gnb@sgi.com>, nfs@lists.sourceforge.net
> Date: Sun, 09 May 2004 20:26:54 -0400
>
> Any thoughts to making this program available anywhere? I'd be
> interested to get some mappings to find out who my most abusive users
> are.

In the meanwhile, you might consider my tools for doing this (as well
as a lot of other things):

http://www.eecs.harvard.edu/sos/software/

nfsdump captures and decodes the NFS requests, and nfsscan does some
analyses on the results.  There are also some helper programs to toss
together quick graphs and things like that.

-Dan



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
