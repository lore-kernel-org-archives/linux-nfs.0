From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Fri, 14 Jan 2005 18:59:30 -0500
Message-ID: <1105747170.28849.22.camel@lade.trondhjem.org>
References: <41E816B3.4030702@mitre.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpbLz-0000xe-HR
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 15:59:43 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CpbLx-00015A-EW
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 15:59:43 -0800
To: Jeff Blaine <jblaine@mitre.org>
In-Reply-To: <41E816B3.4030702@mitre.org>
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

fr den 14.01.2005 Klokka 14:00 (-0500) skreiv Jeff Blaine:
> Can anyone tell me what is happening in the graph at the URL
> below?  I can replicate it on any Linux box running 2.4.21
> and changing rsize/wsize doesn't affect it at all.  This
> was captured from a 2.6GHz P4 client machine.  Same thing
> is visible with a Dual 3GHz Xeon box with 4GB memory as a
> client.  A Solaris 9 client does not display this "falling
> on face" behavior.
> 
> http://www.kickflop.net/temp/sol9-server-linux2421-client-gigE-ag930m_10533_image001.gif

Firstly, you should always use the '-c' flag when measuring NFS client
performance. Otherwise, you are basically just measuring the speed with
which your machine can write to the local page cache (which may indeed
explain your "knee" at 1MB here - that would be where the client starts
to force a flush to disk).

Secondly, have you actually read the NFS FAQ and NFS HOWTO entries on
how to tune for performance? Particularly the entries on TCP vs. UDP,
and how Solaris clients default to the former.

  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
