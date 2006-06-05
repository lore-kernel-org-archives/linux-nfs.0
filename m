From: Damian Pietras <daper@daper.net>
Subject: NFS4 and host restrictions
Date: Mon, 5 Jun 2006 11:23:21 +0200
Message-ID: <20060605092321.GA25450@daper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FnBIx-0004ru-UK
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 02:23:23 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FnBIx-0006Bb-NF
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 02:23:23 -0700
Received: from dust.daper.net ([83.16.99.170] helo=daper.net ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FnBIx-0003p7-2U
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 02:23:23 -0700
Received: from amd.dmp (amd.dmp [172.16.5.1])
	by daper.net (Postfix) with ESMTP id 1AAE54DA2B
	for <nfs@lists.sourceforge.net>; Mon,  5 Jun 2006 11:23:15 +0200 (CEST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I'm trying to work out how to restrict access to NFS4 directories by
client IP.

What I want to achive is something like that:

/nfs4 - virtual root
/nfs4/host1dir
/nfs4/host2dir

I want to restrict access for /nfs4/host1dir to host1 only and for
/nfs4/host2dir to host2.

I've tried few configurations in /etc/exportfs and nothing works, for example:

/nfs4 *(rw,sync,fsid=0)
/nfs4/host1dir host1(rw,sync)
/nfs4/host2dir host2(rw,sync)

This allows anyone to mount /nfs4/host1dir and /nfs4/host2dir

And this:
/nfs4 i127.0.0.1(rw,sync,fsid=0)
/nfs4/host1dir host1(rw,sync)
/nfs4/host2dir host2(rw,sync)

nobody is allowed to mount anything.

I can't figure it out and I couldn't find any information how it's
supposed to work. Can you help me?

I'm using nfs-utils 1.0.7.

-- 
Damian Pietras


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
