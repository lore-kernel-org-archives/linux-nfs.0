From: Robert Myers <rmyers1400@attbi.com>
Subject: Re: Having Trouble Starting NFS
Date: Sun, 22 Jun 2003 13:36:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF5E907.90409@attbi.com>
References: <029DBE7A1D95BF4A860FE19EA15FA533948B@isis.vanderbilt.edu>
Reply-To: rmyers@rustuck.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc12.comcast.net ([216.148.227.85] helo=rwcrmhc12.attbi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19U8lC-00007R-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Jun 2003 10:36:14 -0700
To: Dan Steward <dsteward@isis.vanderbilt.edu>
In-Reply-To: <029DBE7A1D95BF4A860FE19EA15FA533948B@isis.vanderbilt.edu>
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

Dan Steward wrote:

> Hello Gentlemen,
>
> I recently installed Redhat Linux 9.0 on a Compaq laptop. When I try 
> and mount our network NFS, I receive the following error message in 
> the /var/log/messages log file: nfs: mount failure “servername” /home 
> on /auto/home. Can some one please assist this newbie on getting NFS 
> running on this laptop?
>
> Thanks
>
> DS
>
Most probable cause of a failure to mount a remote disk with a naive NFS 
installation is a firewall problem. Try mounting the disk manually while 
watching network traffic with ethereal or tcpdump. Don't be surprised if 
you see a "connection refused" message from a computer that just made an 
NFS request on the same port on which it is refusing to make the connection.

RM




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
