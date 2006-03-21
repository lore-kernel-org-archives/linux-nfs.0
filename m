From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "Permission Denied" when attempting mount command - Any
	help appreciated
Date: Tue, 21 Mar 2006 18:27:06 -0500
Message-ID: <1142983627.9322.24.camel@lade.trondhjem.org>
References: <FB2F81A7764D9244849441E9DC12702B01E06739@teak.vontu.corp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FLqGG-00039r-OR
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 15:27:36 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FLqGE-0001Dx-R8
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 15:27:36 -0800
To: "Brookes, John" <john.brookes@vontu.com>
In-Reply-To: <FB2F81A7764D9244849441E9DC12702B01E06739@teak.vontu.corp>
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

On Tue, 2006-03-21 at 12:18 -0800, Brookes, John wrote:
> I am logged in as root on both machines. I have tried many different
> combinations, but same negative result. 
> Machine A (which is the server in this example) can successfully mount
> the volumes on machine B when it is functioning as client, but not the
> other way around. (as illustrated by the mount command above.)
> 
> Anyone can offer me any clues into this puzzling problem?

RedHat usually offers to set up a firewall for you that can be somewhat
over-restrictive.
Does running '/etc/init.d/iptables stop' on machine A help?

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
