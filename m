From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Wed, 02 Jun 2004 10:53:21 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086188000.7008.1.camel@tesla.mmt.bellhowell.com>
References: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVX7L-0004mj-8C
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 07:53:23 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVX7K-00059b-UF
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 07:53:23 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id 65C52CAF0
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 10:53:13 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 08856-07 for <nfs@lists.sourceforge.net>;
	Wed, 2 Jun 2004 10:53:13 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 1B6637971
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 10:53:13 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
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

Ok, it looks like the problem here was that I already had the filesystem
mounted on another directory as a NFSv2 filesystem. When I unmounted
this filesystem, and remounted it as v3 only, I started getting
performance roughly on par with the 2.4 kernels. Sorry for the false
alarm!
Cheers,
-- Jeff



-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
