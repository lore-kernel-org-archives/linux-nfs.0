From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: permission denied with nfs built into kernel 2.6.13
Date: Tue, 13 Sep 2005 16:35:31 +0200
Message-ID: <200509131635.31902.vincent.roqueta@ext.bull.net>
References: <fd1eac12512fdd18f46a0635cff07b22@leerssen.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFBqF-00060Y-4z
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 07:32:59 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EFBqA-0003mh-GI
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 07:32:59 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4193F19D907
	for <nfs@lists.sourceforge.net>; Tue, 13 Sep 2005 16:32:09 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 10401-02 for <nfs@lists.sourceforge.net>;
 Tue, 13 Sep 2005 16:32:07 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 408BE19DF04
	for <nfs@lists.sourceforge.net>; Tue, 13 Sep 2005 16:32:07 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <fd1eac12512fdd18f46a0635cff07b22@leerssen.com>
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

Le mardi 13 Septembre 2005 16:23, Scott Leerssen a =E9crit=A0:
> Thanks in advance for plowing through this message...
>
> I have NFS built into a 2.6.13 kernel running on Fedora Core 3, and am
> unable to mount a filesystem on the server running the kernel.  Output
> in /var/log/messages seems to indicate a successful mount request:
>
> Sep 13 10:10:41 boot10-5-3-54 rpc.mountd: authenticated mount request
> from 10.5.1.1:870 for /I (/I)
>
> However the client gives me this:
>
> mount: 10.5.3.54:/I failed, reason given by server: Permission denied
>
> Even though from the client:
>
> [root@devmws5 fc3mws]# showmount -e 10.5.3.54
> Export list for 10.5.3.54:
> /I   *
I don't understand what you are exporting.
could you tell me the result of=20
exportfs -v
It should looks like=20
/export_nfs     <world>(rw,wdelay,root_squash)

(nfs3)

Vincent


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
