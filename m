From: Neil Brown <neilb@suse.de>
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Thu, 1 Nov 2007 15:26:31 +1100
Message-ID: <18217.21879.971746.530161@notabene.brown>
References: <2058481856@web.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0548767508=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS@lists.sourceforge.net
To: devzero@web.de
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: message from devzero@web.de on Wednesday October 31
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

--===============0548767508==
Content-Type: text/plain; charset=unknown
Content-Transfer-Encoding: quoted-printable

On Wednesday October 31, devzero@web.de wrote:
> ok, i just wanted to tell that this isn`t the right way to go imho.
>=20
> some time ago i have tested exporting a parent dir containing
> several loopback mounted iso images with some pre-1.1.0 nfs-utils
> version and it worked - so =EC wonder why it now seems to have issues=

> as things should have gone stable.....=20

We have a way of breaking things sometimes.... It's called
"progress". :-)

The short answer is that there is a bug in mountd which is fixed by
this patch:

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ce1a5a9..fd317cd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -508,7 +508,7 @@ void nfsd_fh(FILE *f)
 =09 */
 =09qword_printint(f, 0x7fffffff);
 =09if (found)
-=09=09qword_print(f, found->e_path);
+=09=09qword_print(f, found_path);
 =09qword_eol(f);
  out:
 =09free(found_path);


The longer answer is that there is also a bug in "mount.nfs" which is
unrelated but was slowing me down in chasing this bug, and there is
also a bug in the NFS client which was causing my client oops and need
a reboot every time I triggered this bug in mountd, which further
slowed me down.

The effect of this bug in mountd is that when the NFS client calls
GETATTR on the root of the subordinate filesystem (e.g. your
loop-mounted isos), it got attr information about the parent. ie. the
top-level exported filesystem (/export in your case I think).
This has a different 'fsid' than the nfs client was expecting and
the NFS client got confused in various ways.

Thanks for your problem report - it helped find 3 bugs!

I'll get proper patches or bug report off to the relevant maintainers
shortly.

NeilBrown


--===============0548767508==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============0548767508==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0548767508==--
