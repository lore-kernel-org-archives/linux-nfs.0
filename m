From: "Phrukphicharn, Anuwat" <anuwat@hp.com>
Subject: Re: Permission information on the directory is output with ?
Date: Wed, 13 Jun 2007 15:44:29 +0700
Message-ID: <75A58A7C14469A45BA7A50CDC34EBCF806272180@tlaexc01.asiapacific.cpqcorp.net>
References: <20070524175934.17a59a57.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C7AD97.0E5B2D8B"
Cc: "Phrukphicharn, Anuwat" <anuwat@hp.com>
To: "Shunichi Sagawa" <s-sagawa@jp.fujitsu.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyOTL-0003Lf-NO
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 01:44:59 -0700
Received: from sgprelbas03.asiapac.hp.net ([15.211.153.137])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyOTM-0008Rn-DC
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 01:45:02 -0700
In-Reply-To: <20070524175934.17a59a57.s-sagawa@jp.fujitsu.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

------_=_NextPart_001_01C7AD97.0E5B2D8B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello Shunichi,

I have run the test case for some time, but could not produce such the
symptom (may be I did something wrong). Btw, I have worked with this
symptom on RHEL4, BZ 228801. Which the issue is on the client side. You
may want to check otw attributes of the "incoming" in a GETATTR reply
(for example) if that is correct. I remember that if 'ls -l' think that
an attribute value is not valid it will print "?" or other case is it
cannot retrieve attribute of the file via 'stat("file") call. Which
latter is my case that the client keeps negative dentry and never
invalidate it (as a result, a stat() returns ENOENT as the nfs dentry
revalidation code thinks that it is still valid (so no inode allocated
for the dentry) while the file is already exist on the server).

I attached a discussion and fix code, but I'm not sure if it is included
in the later code (I may not notice if the fix code was revised). Since
the problem can be produced, it may be faster to test the latest bit and
see than to try to read code to find the lines that fix the problem :-)

RH is still working on the above fix. Hope this helps a bit, or too
late?

Regards,
Anuwat

| -----Original Message-----
| From: nfs-bounces@lists.sourceforge.net=20
| [mailto:nfs-bounces@lists.sourceforge.net] On Behalf Of=20
| Shunichi Sagawa
| Sent: Thursday, May 24, 2007 4:00 PM
| To: nfs@lists.sourceforge.net
| Subject: [NFS] Permission information on the directory is=20
| output with ?
|=20
| Hello, all=20
|=20
| I face the problem that the directory's permission=20
| information on NFS server cannot be correctly acquired.
|=20
|   # ls -l /po/spool/postfix
|   total 52
|   drwx------  18 postfix root     4096 May 22 00:45 active
|   drwx------   2 postfix root     4096 Feb 11  2005 bounce
|   drwx------   2 postfix root     4096 Feb 11  2005 corrupt
|   drwx------   5 postfix root     4096 May 22 02:21 defer
|   drwx------   5 postfix root     4096 May 22 02:21 deferred
|   drwx------   2 postfix root     4096 Feb 11  2005 flush
|   -rw-r--r--   1 root    root        0 May 24  2007 hogehoge
|   drwx------   2 postfix root     4096 Feb 11  2005 hold
|   ?---------   ? ?       ?           ?            ? incoming =20
|   <=3D=3D here
|   drwx-wx---   2 postfix postdrop 4096 May 23  2007 maildrop
|   drwxr-xr-x   2 root    root     4096 May 21 14:35 pid
|   drwx------   2 postfix root     4096 May 21 14:35 private
|   drwx--x---   2 postfix postdrop 4096 May 21 14:35 public
|   drwx------   2 postfix root     4096 Feb 11  2005 saved
|   drwx------   2 postfix root     4096 Feb 11  2005 trace
|   #
|=20
| [System configuration]
|=20
|         nfs-server(RHEL4UP3)
|        +- x86 machine ----+
|        |                  |
|        +------------------+             nfs-client(RHEL4UP1)
|           |                            +-x86 machine=20
| -----------------------------------------------+
|           |                    nfs     |                     =20
|                                       |
|        +----disk----------+  <-------> |         mount /po   =20
|    (option noac)                      |
|        | /vol/vol0/jpmail |            |                =20
| |-spool                                    |
|        |                  |            |                 | =20
| |-postfix                               |
|        |                  |            |                 |  |=20
|  |-active                             |
|        |                  |            |                 |  |=20
|  :                                    |
|        |                  |            |                 |  |=20
|  |-incoming(ls -l /po/spool/postfix ?)|
|        |                  |            |                 |  |=20
|  |-maildrop(ls -l /po/spool/postfix ?)|
|        |                  |            |                 |  |=20
|  :                                    |
|        +------------------+            |                =20
| |-vmbox                                    |
|                                       =20
| +------------------------------------------------------------+
|=20
|=20
| [Reproduction procedure]
| If the following operation is done, the output result becomes=20
| abnormal.=20
|=20
| 1. For giving high load, please execute tarloop.sh.
|    This script is accessed to a local disk.
|=20
|   # cat tarloop.sh
|   #!/bin/sh
|   count=3D1
|   while :
|   do
|        time=3D`date`
|        echo "$time count=3D$count"
|        tar xfz ./dummydir.tgz
|        du -a dummydir
|        rm -rf dummydir
|        count=3D$(($count+1))
|   done
|   # ls -l dummydir.tgz
|   -rw-r--r--  1 root root 965148975 May 22 11:59 dummydir.tgz
|   #
|=20
| 2. For NFS access, please execute postfix like this.
|=20
|   # telnet localhost 25
|   Trying 127.0.0.1...
|   Connected to localhost.localdomain (127.0.0.1).
|   Escape character is '^]'.
|   220 hazard.soft.fujitsu.com ESMTP Postfix
|   helo soft.fujitsu.com  -------------------------> (1)
|   250 hazard.soft.fujitsu.com
|   mail from: s-sagawa@jp.fujitsu.com -------------> (2)
|   250 Ok
|   rcpt to: s-sagawa@jp.fujitsu.com ---------------> (3)
|   250 Ok
|   :
|   (1) - (3) repeat.
|=20
|   ###################################################################
|   - The incidence of this problem is about 10%.
|   - When the same procedure is executed after umount/mount is=20
| operated,
|     it is easy to be generated.
|   ###################################################################
|=20
|   [OK pattern]
|   helo soft.fujitsu.com  -------------------------> (1)
|   250 hazard.soft.fujitsu.com
|   mail from: s-sagawa@jp.fujitsu.com -------------> (2)
|   250 Ok
|   rcpt to: s-sagawa@jp.fujitsu.com ---------------> (3)
|   250 Ok
|   [NG pattern]
|   helo soft.fujitsu.com  -------------------------> (1)
|   250 hazard.soft.fujitsu.com
|   mail from: s-sagawa@jp.fujitsu.com -------------> (2)
|   250 Ok
|   rcpt to: s-sagawa@jp.fujitsu.com ---------------> (3)
|=20
|=20
|   When "250 OK" is not output, this problem has been reproduced.
|=20
|   # df
|   Filesystem           1K-blocks      Used Available Use% Mounted on
|   /dev/sda8             19931708  13363664   5555552  71% /
|   none                    517336         0    517336   0% /dev/shm
|   /dev/sdb1             70557052  43613868  23359088  66% /work
|   rhas4up3-part2:/vol/vol0/jpmail
|                          8143616   4978528   2751392  65% /po
|   #
|   # ls -i /po/spool/postfix/
|   339662 active   339665 defer     339719 hogehoge  339670=20
| maildrop  339693 public
|   339663 bounce   339666 deferred  339668 hold      339671=20
| pid       339699 saved
|   339664 corrupt  339667 flush          0 incoming  339673=20
| private   339700 trace
|   #
|   # cd /po/spool/postfix/incoming
|   -bash: cd: /po/spool/postfix/incoming: No such file or directory
|   #
|=20
| What is wrong? And is there any patch?
|=20
|=20
| Regards,
| Sagawa
|=20
| --------------------------------------------------------------
| -----------
| This SF.net email is sponsored by DB2 Express Download DB2=20
| Express C - the FREE version of DB2 express and take control=20
| of your XML. No limits. Just data. Click to get it now.
| http://sourceforge.net/powerbar/db2/
| _______________________________________________
| NFS maillist  -  NFS@lists.sourceforge.net=20
| https://lists.sourceforge.net/lists/listinfo/nfs
|=20

------_=_NextPart_001_01C7AD97.0E5B2D8B
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit

X-MimeOLE: Produced By Microsoft Exchange V6.5
Received: from sgpexg12.asiapacific.cpqcorp.net ([16.149.1.59]) by
	tlaexc01.asiapacific.cpqcorp.net with Microsoft
	SMTPSVC(6.0.3790.1830); Tue, 8 May 2007 19:34:58 +0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Received: from sgprelbas01.asiapac.hp.net ([16.149.0.160]) by
	sgpexg12.asiapacific.cpqcorp.net with Microsoft
	SMTPSVC(6.0.3790.1830); Tue, 8 May 2007 20:34:57 +0800
Received: from ccerelrim03.cce.hp.com (smtp.cce.hp.com [161.114.21.24]) (using
	TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits)) (No client
	certificate requested) by sgprelbas01.asiapac.hp.net (Postfix)
	with ESMTP id 0D75632F93 for <aph7452.routing@ap1.exch.hp.com>;
	Tue,  8 May 2007 20:34:52 +0800 (SGT)
Received: from ccerelrim03.cce.hp.com (localhost [127.0.0.1]) by
	receive-from-antispam-filter (Postfix) with SMTP id 3523233215;
	Tue,  8 May 2007 07:34:50 -0500 (CDT)
Received: from lists-outbound.sourceforge.net (lists-outbound.sourceforge.net
	[66.35.250.225]) by ccerelrim03.cce.hp.com (Postfix) with ESMTP
	id 83F813321B; Tue,  8 May 2007 07:34:49 -0500 (CDT)
Received: from sc8-sf-list2-new.sourceforge.net
	(sc8-sf-list2-new-b.sourceforge.net [10.3.1.94]) by
	sc8-sf-spam2.sourceforge.net (Postfix) with ESMTP id A275F12188;
	Tue,  8 May 2007 05:34:48 -0700 (PDT)
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net) by sc8-sf-list2-new.sourceforge.net
	with esmtp (Exim 4.43) id 1HlOtw-00010G-42 for
	nfs@lists.sourceforge.net; Tue, 08 May 2007 05:34:44 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19lkBFh7xLojMvlsClRyk5RNsxnVOPZfkc=]) by
	mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256) (Exim
	4.44) id 1HlOtx-00011d-Ax for nfs@lists.sourceforge.net;
	Tue, 08 May 2007 05:34:46 -0700
Received: from mail-mx2.uio.no ([129.240.10.30]) by pat.uio.no with esmtp
	(Exim 4.66) (envelope-from <trond.myklebust@fys.uio.no>) id
	1HlOtp-0007Fa-RZ; Tue, 08 May 2007 14:34:37 +0200
Received: from smtp.uio.no ([129.240.10.9] helo=mail-mx2.uio.no) by
	mail-mx2.uio.no with esmtp (Exim 4.66) (envelope-from
	<trond.myklebust@fys.uio.no>) id 1HlOtp-0003HA-6z;
	Tue, 08 May 2007 14:34:37 +0200
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=[192.168.0.173]) by mail-mx2.uio.no with esmtpsa
	(SSLv3:RC4-MD5:128) (Exim 4.66) (envelope-from
	<trond.myklebust@fys.uio.no>) id 1HlOto-0003Gy-QS;
	Tue, 08 May 2007 14:34:37 +0200
Content-class: urn:content-classes:message
Subject: Re: [NFS] time_after cannot be used alone by NFS
	code	in32bit	architectures
Date: Tue, 8 May 2007 19:34:34 +0700
Message-ID: <1178627674.25317.2.camel@heimdal.trondhjem.org>
In-Reply-To: <17984.5736.617053.65429@notabene.brown>
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
Thread-Topic: [NFS] time_after cannot be used alone by NFS
	code	in32bit	architectures
thread-index: AceRbUpO2CcLA2E4QNCoJ6JiHO+Prw==
References: <20070426043344.GO10449@sleipnir.redhat.com><1178106770.5960.28.camel@raven.themaw.net><1178591824.3918.10.camel@raven.themaw.net><17984.5736.617053.65429@notabene.brown>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
From: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Sender: <nfs-bounces@lists.sourceforge.net>
To: "Neil Brown" <neilb@suse.de>
Cc: "linux-nfs" <nfs@lists.sourceforge.net>,
	"Ian Kent" <raven@themaw.net>

On Tue, 2007-05-08 at 16:19 +1000, Neil Brown wrote:
> I'm still having trouble picturing the exact failure mode.
>=20
> The only one I can see is:
>=20
>    Perform a lookup of "foo/bar".
>      Find that it doesn't exist.
>      Create a negative dentry
>    Wait 24 days (jiffie wrap time)
>      During this time the negative dentry
>      is never looked at, and doesn't fall out of cache.
>    Some other access on 'foo' makes sure its
>      change attributes is uptodate
>    Now try to look at foo/bar again.  Due to
>      jiffie wrap, it doesn't seem to be necessary to
>      revalidate, so we don't.
>=20
> Having the negative dentry remain in cache for 24 days while untouched
> seems unlikely?

We can pretty trivially fix that scenario. See below.

Trond

------------------------------------------
commit 6d9b786c6c9b5daf8b20927c7495e42e1c7fde6a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon May 7 22:41:18 2007 -0400

    NFS: Fix a jiffie wraparound issue
   =20
    dentry verifiers are always set to the parent directory's
    cache_change_attribute. There is no reason to be testing for =
anything other
    than equality when we're trying to find out if the dentry has been =
checked
    since the last time the directory was modified.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 625d8e5..fced7d1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -650,12 +650,17 @@ int nfs_fsync_dir(struct file *filp, struct dentry =
*dentry, int datasync)
  */
 static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 {
+	unsigned long verf;
+
 	if (IS_ROOT(dentry))
 		return 1;
+	verf =3D (unsigned long)dentry->d_fsdata;
 	if ((NFS_I(dir)->cache_validity & NFS_INO_INVALID_ATTR) !=3D 0
-			|| nfs_attribute_timeout(dir))
+			|| nfs_attribute_timeout(dir)
+			|| nfs_caches_unstable(dir)
+			|| verf !=3D NFS_I(dir)->cache_change_attribute)
 		return 0;
-	return nfs_verify_change_attribute(dir, (unsigned =
long)dentry->d_fsdata);
+	return 1;
 }
=20
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned =
long verf)
@@ -665,8 +670,7 @@ static inline void nfs_set_verifier(struct dentry * =
dentry, unsigned long verf)
=20
 static void nfs_refresh_verifier(struct dentry * dentry, unsigned long =
verf)
 {
-	if (time_after(verf, (unsigned long)dentry->d_fsdata))
-		nfs_set_verifier(dentry, verf);
+	nfs_set_verifier(dentry, verf);
 }
=20
 /*



-------------------------------------------------------------------------=

This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------_=_NextPart_001_01C7AD97.0E5B2D8B
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
------_=_NextPart_001_01C7AD97.0E5B2D8B
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------_=_NextPart_001_01C7AD97.0E5B2D8B--
