From: Ian Kent <raven@themaw.net>
Subject: RE: mtab and procs not in sync?
Date: Wed, 9 Jun 2004 10:20:06 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0406091012060.12971@wombat.indigo.net.au>
References: <482A3FA0050D21419C269D13989C61130435E229@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Phy Prabab <phyprabab@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXsXg-0007BB-Er
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 19:10:16 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BXsXe-0003Ae-WB
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 19:10:15 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E229@lavender-fe.eng.netapp.com>
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

On Tue, 8 Jun 2004, Lever, Charles wrote:

> if there are a lot of mounts on the system, then /proc/mounts can be
> truncated and not show all of them.

That's very cool.
And a timely piece of information since I was about to change autofs to 
rely on it instead of mtab.

So we can't rely on /proc/mounts being correct?
And mount consistently corrupts /etc/mtab under load.
And the util-linux list is closed and unresponsive last time I tried.

I will need to revisit this to give an account of what I think may be 
wrong with mounts mtab locking. Indeed, I have couple of questions about 
how it is supposed to work as it's not clear from the code.

Have you got any ideas how I could get the attention of the maintainer of 
mount?

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
