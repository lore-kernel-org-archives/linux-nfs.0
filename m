From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: broken_suid mount option
Date: Sun, 5 Sep 2004 23:55:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040905215558.GA29526@janus>
References: <20040905213702.GA29401@janus> <1094420629.8081.39.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@xs4all.nl>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C44zU-0007r1-0Z
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 14:56:04 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C44zP-0000ty-JN
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 14:56:01 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094420629.8081.39.camel@lade.trondhjem.org>
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

On Sun, Sep 05, 2004 at 05:43:49PM -0400, Trond Myklebust wrote:
> 
> Just yesterday I saw traces made on a college server by a student this
> summer in which >99% of the traffic was broken lookups of .Xauthority by
> 'root' processes...

So they run old XFree86 software with broken setuid programs and
compensate using the broken_suid mount option. They probably use
an old kernel as well. Isn't it time to change this for 2.6?
You mentioned the word "security" ;-)

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
