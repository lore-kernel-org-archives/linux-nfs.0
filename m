From: Sampo Nurmentaus <audiopoppi-13@audioriders.fi>
Subject: Problem with nfs v3 and embedded clients.
Date: Mon, 17 Mar 2003 20:08:31 +0200 (EET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0303171948300.7768-100000@localhost>
Reply-To: <sampo.nurmentaus@audioriders.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs150121.pp.htv.fi ([213.243.150.121])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18uz8J-0000aV-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Mar 2003 10:14:47 -0800
Received: from [10.69.69.10] (kombo-vpn [10.69.69.10])
	by cs150121.pp.htv.fi (8.11.6/8.11.6) with ESMTP id h2HIEt715103
	for <nfs@lists.sourceforge.net>; Mon, 17 Mar 2003 20:14:55 +0200
To: <nfs@lists.sourceforge.net>
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


Hello folks,

We have had some serious problems with running
on a linux pc with embedded clients connecting to it.

Have no idea why but when the system is set up
all the clients can mount nfs share after about three
tries!

And after a while things get even worse, the client
can not mount at all from this the system recovers
after cleaning up /var/lib/nfs

The error message at client end states that
RPC call has timed out. The syslock of the
server has only a statement about succesfull
authentication of the client and the client
appears in /var/lib/nfs/xtab.

We have tried different variations with and without
nolock etc.

Not so exact problem description but I am running out of
debugging means.

Anyone seen behaviour like this before?


Thank You in advance,

Sampo Nurmentaus



-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
