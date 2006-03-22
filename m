From: "Brookes, John" <john.brookes@vontu.com>
Subject: RE: "Permission Denied" when attempting mount command - Anyhelp appreciated
Date: Tue, 21 Mar 2006 16:20:59 -0800
Message-ID: <FB2F81A7764D9244849441E9DC12702B01E0673D@teak.vontu.corp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FLr75-0000vO-9n
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 16:22:11 -0800
Received: from dsl081-249-146.sfo1.dsl.speakeasy.net ([64.81.249.146] helo=sentinal.vontu.corp)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FLr73-0001yJ-Tp
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 16:22:11 -0800
Received: from teak.vontu.corp (teak.vontu.corp [10.67.20.15])
	by sentinal.vontu.corp with ESMTP id k2M0LHgb005224
	for <nfs@lists.sourceforge.net>; Tue, 21 Mar 2006 16:21:17 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Trond,
That worked!
Thank you much - you made my day!
John B

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]=20
Sent: Tuesday, March 21, 2006 3:27 PM
To: Brookes, John
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] "Permission Denied" when attempting mount command -
Anyhelp appreciated


On Tue, 2006-03-21 at 12:18 -0800, Brookes, John wrote:
> I am logged in as root on both machines. I have tried many different=20
> combinations, but same negative result. Machine A (which is the server

> in this example) can successfully mount the volumes on machine B when=20
> it is functioning as client, but not the other way around. (as=20
> illustrated by the mount command above.)
>=20
> Anyone can offer me any clues into this puzzling problem?

RedHat usually offers to set up a firewall for you that can be somewhat
over-restrictive. Does running '/etc/init.d/iptables stop' on machine A
help?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
