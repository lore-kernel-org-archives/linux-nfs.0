From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Exportfs and rpc.mountd optimalization - patch
Date: Mon, 22 Aug 2005 18:05:14 +0200
Message-ID: <200508221805.14998.vincent.roqueta@ext.bull.net>
References: <42B86FB9.6060102@gmail.com> <20050822155320.GC12618@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E7Ejs-0002o0-CF
	for nfs@lists.sourceforge.net; Mon, 22 Aug 2005 09:01:32 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E7Ejq-0007k1-TN
	for nfs@lists.sourceforge.net; Mon, 22 Aug 2005 09:01:32 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 5779219DF04
	for <nfs@lists.sourceforge.net>; Mon, 22 Aug 2005 18:00:49 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 17281-04 for <nfs@lists.sourceforge.net>;
 Mon, 22 Aug 2005 18:00:48 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id B084819D913
	for <nfs@lists.sourceforge.net>; Mon, 22 Aug 2005 18:00:47 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20050822155320.GC12618@fieldses.org>
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

Le lundi 22 Ao=FBt 2005 17:53, J. Bruce Fields a =E9crit=A0:
> Vincent, have you tried rerunning your export-scalability test with this
> patch applied to see if it helps?
>
> --b.

I can test for nfsv3 if that is important?=20

V.


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
