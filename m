From: raven@themaw.net
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 17:32:41 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0408281730150.1412@donald.themaw.net>
References: <20040827212244.GA57703@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0zhY-00077X-Np
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 02:40:48 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0zhW-0003L0-N7
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 02:40:48 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <20040827212244.GA57703@brandon.dvalentine.com>
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

On Fri, 27 Aug 2004, Brandon D. Valentine wrote:

> Autofs is configured on the FC2 systems to permit NFSv2 mounts as shown
> by the minproto option below:
> 
>   [root@scylla root]# mount | grep automount
>   automount(pid1665) on /home type autofs (rw,fd=4,pgrp=1665,minproto=2,maxproto=4)
>   automount(pid1695) on /sb type autofs (rw,fd=4,pgrp=1695,minproto=2,maxproto=4)
>   automount(pid1739) on /scratch type autofs (rw,fd=4,pgrp=1739,minproto=2,maxproto=4)

The minproto and maxproto have nothing to to with NFS version. They are 
related to the autofs kernel module <-> automount daemon communication.

Ian



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
