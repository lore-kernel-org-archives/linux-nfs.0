From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Problems with statd and lockd
Date: Sat, 5 Apr 2003 01:56:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pgramoul.net2.nerim.net ([80.65.227.234] helo=philou.aspic.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191b3J-0000f3-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Apr 2003 15:56:57 -0800
Received: from philou.gramoulle.local (philou.gramoulle.local [192.168.254.2])
	by philou.aspic.com (Postfix) with SMTP id 91CA8278E
	for <nfs@lists.sourceforge.net>; Sat,  5 Apr 2003 01:56:38 +0200 (CEST)
To: NFS Mailing List <nfs@lists.sourceforge.net>
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


Hi,

Recently we started to get the following error messages on an Linux NFS server, running
2.4.21-pre5 vanilla, Debian unstable

 > statd: server localhost not responding, timed out
 > nsm_mon_unmon: rpc failed, status=-5
 > lockd: cannot monitor <Client IP here>

A restart of nfs-kernel-server cleared the problem.

We have filesystems that are exported sync, other are exported async.

Can you tell me what the "-5" return code means ?

I've looked at the source code (nsm_mon_unmon in mon.c
that sends back to nfs3proc.c and the rpc_call wrapper
but i'm lost after that :)

Can someone enlighten me ?

Thanks,

Philippe


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
