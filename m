From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: readdir and readdirplus...
Date: 24 Sep 2003 09:00:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsfzimi3bn.fsf@charged.uio.no>
References: <8147E1B07201DD41B6B9F0D31E07B384016486A6@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2C4e-0004vH-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 09:01:04 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2C4c-0004yk-L9
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 09:01:02 -0700
To: Brasseur =?iso-8859-1?q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8147E1B07201DD41B6B9F0D31E07B384016486A6@srv-grp-s07.dev.atos.fr>
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

>>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> writes:

     > I am using a linux 2.4.20+NFS-ALL patches.  my server is a
     > Netapp Filer

     > I am using NFSv3

     > what I did not understand is that it's seems that linux does
     > not use READDIRPLUS ... is it normal ? in sources I have seen
     > that certain condition should be met... but I never see any
     > READDIRPLUS request !!!

My machine currently shows the following statistics against a filer:

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 6405   36% 777     4% 1719    9% 3534   20% 119     0%
read       write      create     mkdir      symlink    mknod
2340   13% 1645    9% 155     0% 4       0% 2       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
165     0% 3       0% 13      0% 37      0% 21      0% 631     3%
fsstat     fsinfo     pathconf   commit
50      0% 5       0% 0       0% 0       0%

So READDIRPLUS should normally be quite usable. Are you sure that=20
the patches applied cleanly?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
