From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: Q: NFS server cluster
Date: Sat, 01 Apr 2006 07:16:06 -0500
Message-ID: <1143893766.13560.9.camel@localhost.localdomain>
References: <20060331160217.1734f710@mwdsp001.swissptt.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPf27-0005dN-0i
	for nfs@lists.sourceforge.net; Sat, 01 Apr 2006 04:16:47 -0800
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FPf26-0005OE-GP
	for nfs@lists.sourceforge.net; Sat, 01 Apr 2006 04:16:46 -0800
Received: from ibm63aec.bellsouth.net ([72.148.41.34])
          by imf21aec.mail.bellsouth.net with ESMTP
          id <20060401121609.MTGZ22697.imf21aec.mail.bellsouth.net@ibm63aec.bellsouth.net>
          for <nfs@lists.sourceforge.net>; Sat, 1 Apr 2006 07:16:09 -0500
To: Chris Osicki <osk@admin.swisscom-mobile.ch>
In-Reply-To: <20060331160217.1734f710@mwdsp001.swissptt.ch>
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

On Fri, 2006-03-31 at 16:02 +0200, Chris Osicki wrote:
> Is there anything I can do to eliminate this behaviour?
> If I understand correctly the problem is on the server side for the
> client nothing changes, the same IP-address to talk to, the same
> filesystem/filehandle. Or am I missing something.
> 

Be sure the blockdev has the same device major/minor number on both
hosts, though it sounds like you may already have checked that.

Otherwise, this sounds a lot like an issue with ARP. When you float IP
addresses you need to have the new address owner send gratuitous ARPs so
that its neighbors update their caches. Make sure your failover software
is doing this, and that the client and/or router isn't ignoring them.

-- Jeff




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
