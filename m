From: Ian Kent <raven@themaw.net>
Subject: Re: mtab and procs not in sync?
Date: Wed, 9 Jun 2004 10:11:29 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0406090957590.12971@wombat.indigo.net.au>
References: <20040608182036.78593.qmail@web51805.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXsOz-0005Tt-4X
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 19:01:17 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BXsOy-0008Md-Et
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 19:01:16 -0700
To: Phy Prabab <phyprabab@yahoo.com>
In-Reply-To: <20040608182036.78593.qmail@web51805.mail.yahoo.com>
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

On Tue, 8 Jun 2004, Phy Prabab wrote:

> Hello,
> 
> Have run into a situation where mtab does not match
> /proc/mounts in that mtab has numerous entries that
> have expired off and removed, yet does not show that
> it has been removed from mtab.  Is this known and is
> there a fix?

This is not an NFS, kernel or automount issue.

The locking in mount appears to be broken. It usually shows up with autofs 
because it put quite a bit of pressure on mount.

But what is your environment?
I need more info. to understand this.
What 4.1.2 patches, if any, have you applied?

> 
> Kernel 2.4.21 and 23
> nfs-utils 1.06
> automount 4.1.2

I've tried to work around this problem and I discovered a coding error 
with that work the other day. I have a patch available at 

http://www.kernel.org/pub/linux/daemons/autofs/v4

called 

autofs-4.1.3-mtab_lock.patch

It is against 4.1.3 but should apply OK to 4.1.2.

This problem probably belongs on the autofs list. You can subscribe at
http://linux.kernel.org/mailman/listinfo/autofs

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
