From: "Daniel Amthor" <da@lonx.net>
Subject: Re: NFS refusing to perform when backup ISDN link is up
Date: Sat, 11 Mar 2006 09:03:31 +0100 (CET)
Message-ID: <61900.172.180.51.9.1142064211.squirrel@otto.lonx.net>
References: <47324.62.159.242.114.1141983018.squirrel@otto.lonx.net>
    <1142001156.8041.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHz4n-0003fl-6K
	for nfs@lists.sourceforge.net; Sat, 11 Mar 2006 00:03:49 -0800
Received: from subzero.webdirekt.de ([195.243.240.4] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHz4m-0002yh-R7
	for nfs@lists.sourceforge.net; Sat, 11 Mar 2006 00:03:49 -0800
In-Reply-To: <1142001156.8041.5.camel@lade.trondhjem.org>
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

Hi ,
thanks for that and quite right.

> rpc.mountd and rpc.statd both need BIND lookup services in order to
> resolve the entries in /etc/exports. If those are running over the ISDN
> link, then that might explain some of the issues you are seeing.
The issue was along these lines, but a  little more involved and I though=
t
I'd let the list know.  One of the DNS is local and two remote. rpc.mount=
d
tries to look up the non-fqdns, DNS delivers "servfail" and tries the nex=
t
server, with long DNS timeout. Solution was to use the "domain"-statement
in resolv.conf instead of the "search"-directive. Then lookups take place
for the right fqdn and stay with the local DNS. To fiurther improve the
scene I implemented a caching nameserver on the NFS-Server.
Thanks for your help

Cheers
Dan



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
