From: James Yarbrough <jmy@sgi.com>
Subject: Re: Is this possible using NFS ?
Date: Wed, 24 Aug 2005 15:18:05 -0700
Message-ID: <430CF21D.EC268F1E@sgi.com>
References: <1124140386.11051.22.camel@rudi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E83ZV-0005Rj-Jp
	for nfs@lists.sourceforge.net; Wed, 24 Aug 2005 15:18:13 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E83ZU-0000eb-9U
	for nfs@lists.sourceforge.net; Wed, 24 Aug 2005 15:18:13 -0700
To: Roger Zimmermann <Roger.Zimmermann@arcor.de>
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

Roger,

I think the answer to this question is going to be "no" unless you
have only one client.  There is an export option that might do what
you want, it just may not work very well.  Read about the nohide
option in the exports(5) man page.  You can try out that export option
and see if it works for you.  I tend to avoid it, though.

Roger Zimmermann wrote:
> 
> Hi,
> 
> I've got a server, where a varying number of disks is connected.
> The layout:
> 
> /exampledir/onedisk/sometimes-mounted/etc
> /exampledir/onotherdisk/sometimes-mounted/etc
> /exampledir/harddisk/always-mounted
> /exampledir/otherdata
> 
> can I simply export /exampledir from the server
> and mount it via NFS by clients without having each client to inform
> when e.g 'onedisk' is connected or removed ?
> 
> THNX, Roger
> 
> -------------------------------------------------------
> SF.Net email is Sponsored by the Better Software Conference & EXPO
> September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
> Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
> Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
jmy@sgi.com
650 933 3124

McGoogles is me name, I like a cup a' joe.
Throw me in the padded room, and tie me up with rope.


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
