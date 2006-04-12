From: Vince Busam <vbusam@google.com>
Subject: Re: fileid changed messages appearing after upgrade to	2.6.16.1
Date: Tue, 11 Apr 2006 21:13:36 -0700
Message-ID: <443C7E70.6090905@google.com>
References: <443C69CB.4060503@google.com> <1144811431.8069.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTWjp-0007H2-8t
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 21:13:53 -0700
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FTWjo-00036I-1V
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 21:13:53 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1144811431.8069.6.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> What did you upgrade? The client or the server?

Just the client, which is where this warning started showing up.

> What mount options etc,

rw,nosuid,tcp,rsize=8192,wsize=8192,intr,bg (nfsv3)

I haven't been able to narrow down what happened in userspace to cause 
this, and haven't seen any ill effects to userspace programs.

Vince


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
