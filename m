From: Paul Jakma <paul@clubi.ie>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Fri, 20 Jun 2003 03:10:01 +0100 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0306200308170.16473-100000@fogarty.jakma.org>
References: <3EF1CC36.8F3EC825@moving-picture.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>,
   <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hibernia.jakma.org ([212.17.36.87])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TBOl-0006hs-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 19:13:09 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3EF1CC36.8F3EC825@moving-picture.com>
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

On Thu, 19 Jun 2003, James Pearson wrote:

> The device on the server containing the file system changes e.g.
> change of SCSI ID.

isnt there an export option to allow one to 'batton-down' the 
exported NFS device (and hence abstract it from the real device id on 
the NFS server)?

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
Someday somebody has got to decide whether the typewriter is the machine,
or the person who operates it.



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
