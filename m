From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Fri, 27 Aug 2004 17:36:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093642565.5758.108.camel@lade.trondhjem.org>
References: <20040827212244.GA57703@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0oOJ-0005ZB-8G
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 14:36:11 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0oOH-00035i-M0
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 14:36:11 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <20040827212244.GA57703@brandon.dvalentine.com>
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

P=E5 fr , 27/08/2004 klokka 17:22, skreiv Brandon D. Valentine:

> Given the fact that the mount fails manually until vers=3D2 is specified =
I
> am inclined to believe this is a kernel NFS bug, not an autofs or mount
> bug.

Sorry. I conclude the exact opposite. The problem here is the "mount"
program autoprobe failing.

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
