From: Chris Osicki <osk@admin.swisscom-mobile.ch>
Subject: Re: Q: NFS server cluster
Date: Tue, 4 Apr 2006 15:12:47 +0200
Message-ID: <20060404151247.081c0c22@mwdsp001>
References: <20060331160217.1734f710@mwdsp001.swissptt.ch>
	<1143893766.13560.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQlLR-00080J-MD
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 06:13:17 -0700
Received: from outmail3.swisscom.com ([138.190.3.30] helo=mrz.swissptt.ch)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FQlLP-0001Hn-No
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 06:13:17 -0700
Received: from mwdsp001.swissptt.ch (mwdsp001.swissptt.ch [10.221.40.203])
	by mrz.swissptt.ch with ESMTP id k34DCos6006895
	(using TLSv1/SSLv3 with cipher EDH-RSA-DES-CBC3-SHA (168 bits) verified NO)
	for <nfs@lists.sourceforge.net>; Tue, 4 Apr 2006 15:12:50 +0200 (MEST)
Received: from mwdsp001 (localhost [127.0.0.1])
	by mwdsp001.swissptt.ch (8.13.4/8.13.4) with ESMTP id k34DCme8011516
	for <nfs@lists.sourceforge.net>; Tue, 4 Apr 2006 15:12:48 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <1143893766.13560.9.camel@localhost.localdomain>
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

On Sat, 01 Apr 2006 07:16:06 -0500
Jeff Layton <jtlayton@poochiereds.net> wrote:

> On Fri, 2006-03-31 at 16:02 +0200, Chris Osicki wrote:
> > Is there anything I can do to eliminate this behaviour?
> > If I understand correctly the problem is on the server side for the
> > client nothing changes, the same IP-address to talk to, the same
> > filesystem/filehandle. Or am I missing something.
> > 
> 
> Be sure the blockdev has the same device major/minor number on both
> hosts, though it sounds like you may already have checked that.
> 
> Otherwise, this sounds a lot like an issue with ARP. When you float IP
> addresses you need to have the new address owner send gratuitous ARPs so
> that its neighbors update their caches. Make sure your failover software
> is doing this, and that the client and/or router isn't ignoring them.
> 
> -- Jeff
> 
> 


Thanks for your reply, Jeff. 
The problem was self-induced. My fail-over script trying to free the 
filesystem (on the server) in order to umount it incorrectly used
"fuser" and killed the rpc.mountd.  It works as expected now.

Regards,
Chris


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
