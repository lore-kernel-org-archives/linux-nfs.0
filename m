From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Tue, 7 Nov 2006 01:47:20 +0100
Message-ID: <20061107004720.GA16731@uio.no>
References: <4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
	<20061031143248.GA8444@uio.no> <20061103123737.GA5199@uio.no>
	<4d569c330611061508g5e9044cdy36d87ae2ac03952d@mail.gmail.com>
	<20061106231539.GI12372@fieldses.org>
	<20061106231615.GA17582@uio.no>
	<20061106231821.GK12372@fieldses.org>
	<20061106232224.GL12372@fieldses.org>
	<20061106234607.GA18236@uio.no>
	<20061106234922.GM12372@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhF8g-00006v-IY
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 16:48:30 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhF8f-00024h-4b
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 16:48:31 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061106234922.GM12372@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, Nov 06, 2006 at 06:49:22PM -0500, J. Bruce Fields wrote:
>> http://home.samfundet.no/~sesse/svcgssd-strace.log.bz2
> 18:48:39 ERROR 404: Not Found.

Hm, that's odd. Oh well, I found a log here now, at least -- try it now.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
