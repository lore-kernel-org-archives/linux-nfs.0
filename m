From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 01:35:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093671305.6028.46.camel@lade.trondhjem.org>
References: <20040827212244.GA57703@brandon.dvalentine.com>
	 <1093642565.5758.108.camel@lade.trondhjem.org>
	 <1093643490.5758.120.camel@lade.trondhjem.org>
	 <20040827233235.GB57703@brandon.dvalentine.com>
	 <20040827233431.GC57703@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0vrq-0006HF-Mj
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 22:35:10 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0vro-0008Ad-UU
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 22:35:10 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <20040827233431.GC57703@brandon.dvalentine.com>
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

P=E5 fr , 27/08/2004 klokka 19:34, skreiv Brandon D. Valentine:
> And of course I didn't actually attach the strace output file so here it
> comes.  Sorry for the extra message.

It all looks OK, apart from the fact that the mount program gives up
after it receives the PROG_MISMATCH reply from the server.

Mind applying the following debugging line to the util-linux SRPM, then
using the resulting "mount" to test out what is going wrong?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
