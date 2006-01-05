From: Herbert Engelmann <Herbert.Engelmann@lrz-muenchen.de>
Subject: lockd/statd: failed to create /var/lib/nfs/sm/<hostname>
Date: Thu, 5 Jan 2006 14:56:18 +0100
Message-ID: <200601051456.20478.engelmann@lrz.de>
Reply-To: Herbert.Engelmann@lrz-muenchen.de
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Cc: Helge.Hansemann@lrz-muenchen.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EuVbN-00054r-5u
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 05:56:25 -0800
Received: from mailrelay2.lrz-muenchen.de ([129.187.254.102])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EuVbL-0007Ku-OZ
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 05:56:25 -0800
To: nfs@lists.sourceforge.net
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

=2D----BEGIN PGP SIGNED MESSAGE-----

Hi,

I get the following messages in my /var/log/messages:

Jan  5 10:58:10 xxxxxx kernel: lockd/statd: failed to create=20
/var/lib/nfs/sm/<full qualified hostname>: err=3D-2

Jan  5 10:58:10 xxxxxx kernel: lockd: failed to monitor <full qualified=20
hostname>

This happens, when I upload a file to my ftp-server. The server accepts
the uploaded file alright, but it cannot write the log-file. Both files,
the uploaded file and the log-file, reside in the same filesystem, which
is mounted via nfs.=20

The directory /var/lib/nfs/sm exists. When I mount the filesystem with
the option "nolock", then the log-file gets written. I can not use this
option, because I need the content of the log-file to process the uploaded
files and therefore it is important, that this content is consistent.

What can I do to get it right?

Thanks=20

Herbert Engelmann
=2D --=20
H. Engelmann, 089-289-28836, engelmann@lrz.de
PGP-Key : http://www.lrz-muenchen.de/~engelmann/info/pgp.em.html

=2D----BEGIN PGP SIGNATURE-----
Version: 2.6.3in
Charset: noconv

iQCVAwUBQ70lg6hxGsmXUG+lAQF1KQP9ENS7aI/7GSmfsJcGQr/+qa181fZkw6E8
ll6FCih6/NQ0jXm54+xPnVvM3VCWK5inULndB4clTo6xuk+EutLtGhdZFFJMXXyH
EJTqwbFqWNV1a5kPy/GxeVipUZ7i2DpEWv3g5siLktbxTAmvpLs0KXDGlFGDwxZt
BYuUglP+wzs=3D
=3DB0oS
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
