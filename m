From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: readdir and readdirplus...
Date: Wed, 24 Sep 2003 11:07:45 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16241.56689.19520.96114@charged.uio.no>
References: <8147E1B07201DD41B6B9F0D31E07B384016486B1@srv-grp-s07.dev.atos.fr>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2E3P-0000JN-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 11:07:55 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2E3O-0006pJ-Q7
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 11:07:55 -0700
To: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8147E1B07201DD41B6B9F0D31E07B384016486B1@srv-grp-s07.dev.atos.fr>
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

>>>>> " " == Brasseur Valéry <Valery.Brasseur@atosorigin.com> writes:

     > here is one of my nfsstat : Client nfs v3: null getattr setattr
     > lookup access readlink 0 0% 771483726 1% 6109 0% 827366925 0%
     > 1040368089 0% 4862868 0% read write create mkdir symlink mknod
     > -1853693236 1% 1340911105 0% 132162422 0% 260671 0% 8216 0% 0
     > 0% remove rmdir rename link readdir readdirplus 174498032 0%
     > 1639 0% 210405486 1% 44505153 0% 5748 0% 155051 0% fsstat
     > fsinfo pathconf commit 34851 0% 3 0% 0 0% 0 0%

     > and the patch apply cleanly !  any way to verify ?

So... According to this, your NFSv3 client has made 155051 readdirplus
calls. Am I missing something?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
