From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Recent intermittent problem authenticating clients against NFS.
Date: Thu, 31 Oct 2002 11:12:16 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15808.30048.877068.46940@notabene.cse.unsw.edu.au>
References: <3DC06A8D.8020706@willamette.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872wr-0007te-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 16:12:34 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <speralta@willamette.edu>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 31 Oct 2002 11:12:19 +1100
To: Salvador Peralta <speralta@willamette.edu>
In-Reply-To: message from Salvador Peralta on Wednesday October 30
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

On Wednesday October 30, speralta@willamette.edu wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Hello all,
> 
> We are experiencing an (apparently) recent phenomenon involving
> intermittent problem authenticating clients against NFS.
> 
> Clients can generally connect, but periodically, a random given client
> will attempt to authenticate against NFS, and will fail with  (example)
> "Oct 30 14:02:46 info-1 rpc.mountd: refused mount request from lib-ncd9
> for /home (/): no export entry"  logged in /var/log/messages.

The client is trying to mount "/home" but...

> $ cat /etc/exports
> /export *(ro)
> /home/ncbridge *(ro)
> /home/tekxp *(ro)
> 

/home is not exported..

Client config problem?

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
