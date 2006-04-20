From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Newbie NFS permissions question.
Date: Thu, 20 Apr 2006 05:31:39 -0400
Message-ID: <444754FB.7080300@RedHat.com>
References: <200604200906.k3K96LXx015413@main.games-master.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWVWD-0001pX-MA
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 02:32:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FWVWB-0007sv-Db
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 02:32:09 -0700
To: Tony <tony@games-master.co.uk>
In-Reply-To: <200604200906.k3K96LXx015413@main.games-master.co.uk>
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

Tony wrote:
> I've now got 2 new servers and have been able to NFS mount a share from
> server 1 to server 2.
This confuses me... You mean a "share from server 1 _and_ server 2"
right?

> I can chmod, chown and chgrp of files and directories on server 2 as long as
> the user and group exist on server 1.
> Is this the default behaviour for NFS?
No... this does not make any senses...

> Does the user and group have to exist on the server sharing?
In general, the user and group should exist on both the server
and client; but the user and group ids do not have to explicitly
exist on the server...

> Is there a way of being able to change the ownership of a file or directory
> without the user or/and group having to exist on the server allowing the
> share?
Yes... On the server export the filesystem with the 'no_root_squash'
option which will allow root on the client to change ownerships with
the chown command.

steved.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
