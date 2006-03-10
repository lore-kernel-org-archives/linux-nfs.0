From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS refusing to perform when backup ISDN link is up
Date: Fri, 10 Mar 2006 09:32:35 -0500
Message-ID: <1142001156.8041.5.camel@lade.trondhjem.org>
References: <47324.62.159.242.114.1141983018.squirrel@otto.lonx.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHig7-0005zd-Qs
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 06:33:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHig6-0006im-Eo
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 06:33:15 -0800
To: Daniel Amthor <da@lonx.net>
In-Reply-To: <47324.62.159.242.114.1141983018.squirrel@otto.lonx.net>
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

On Fri, 2006-03-10 at 10:30 +0100, Daniel Amthor wrote:
> Hello List,
> our setup:
> 25 Solaris Clients bound to a Linux SLES 9 Server (2.6.5-7-139)
> Authentication and NameServices run locally and on as a backup a remote
> site connected via Fibre Optics. When the Fibre Link goes down a 384k ISDN
> backup fails in.
> The Scene:
> When ISDN failover occurs the local client performance goes down rapidly,
> even though all traffic stays local. We get "RPC timeout" as well as some
> "Permission denied" in the logs. Quite erratic, sometime it works,
> sometimes it does not. I've read the NFS FAQ and figured maybe MTU and
> fragmentation, but then all traffic should be local.
> Any ideas or experiences ?
> Best
> Dan

rpc.mountd and rpc.statd both need BIND lookup services in order to
resolve the entries in /etc/exports. If those are running over the ISDN
link, then that might explain some of the issues you are seeing.

Try adding the clients to /etc/hosts on the server and then check
that /etc/nsswitch.conf does local file lookup before dns by changing
your 'hosts' entry to

hosts:		files dns

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
