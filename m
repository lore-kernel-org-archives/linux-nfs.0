From: zfadli@sinasolutions.com
Subject: RedHat 7.1+ Sol 8
Date: Tue, 11 Jun 2002 07:41:07 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <11638.205.188.195.41.1023795667.squirrel@mail.sinasolutions.com>
References: <20020611042508.31527.qmail@web21106.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.205.37.251] (helo=mail.sinasolutions.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17HkCS-0005Ze-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Jun 2002 04:52:36 -0700
To: <signalsvr@yahoo.co.uk>
In-Reply-To: <20020611042508.31527.qmail@web21106.mail.yahoo.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,
I am using Redhat 7.1 as my NFS server. I have edited /etc/exports and
when I ran "rpcinfo -p localhost" I got all the daemons and their ports
correctly.
On the client side, I have Solaris 8. Everytime I try to mount I get the
follwoing error.
nfs mount: x.x.x.x: : RPC: Rpcbind failure - RPC: Unable to receive
nfs mount: retrying: /dump

And it keeps on trying.

I have checked everything that I can think off. From portmap to
hosts.allow/.deny
I am clueless! Any help plz>

Thanks









> Hi,
> You may be aware of the LLOCK option in NFS mount.  It
> enables the lock in the client side.  I am not sure
> what kind of lock it is and how do I check if the lock
> is really imposed... any light on this would be
> greatly appreciated...
>
> Thanks a lot for any help!
>
> Regards,
> SVR.
>
> __________________________________________________
> Do You Yahoo!?
> Everything you'll ever need on one web page
> from News and Sport to Email and Music Charts
> http://uk.my.yahoo.com
>
> _______________________________________________________________
>
> Don't miss the 2002 Sprint PCS Application Developer's Conference
> August 25-28 in Las Vegas -
> http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
