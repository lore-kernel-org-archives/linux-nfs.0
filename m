From: Olaf Kirch <okir@suse.de>
Subject: Re: userspace NFS daemon
Date: Tue, 7 Sep 2004 12:40:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040907104047.GA11764@suse.de>
References: <Pine.LNX.4.44.0409060210030.12696-100000@kenzo.iwr.uni-heidelberg.de> <1094441577.10492.134.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
	Frank van Maarseveen <frankvm@xs4all.nl>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4dP9-0005OA-08
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 03:40:51 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C4dP8-0006kM-Cq
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 03:40:50 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094441577.10492.134.camel@lade.trondhjem.org>
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

On Sun, Sep 05, 2004 at 11:32:57PM -0400, Trond Myklebust wrote:
> No. I mean that very few people have ever used unfsd in mission-critical
> production environments.
> You might get away with it for read-only stuff (if you are prepared to
> put up with the speed), but nobody should be using it for read/write
> partitions.

Suse actually used it for /home until about 1.5 years ago or even
less, and we had less problems than with knfsd.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
