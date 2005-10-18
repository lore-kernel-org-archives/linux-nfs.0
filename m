From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 09:10:29 -0700
Message-ID: <1129651829.8989.17.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JK6XxfoONTx7cV0aDYx1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERu6W-0001Fu-8r
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 09:14:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERu6P-0005FF-I3
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 09:14:17 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com>
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


--=-JK6XxfoONTx7cV0aDYx1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

m=C3=A5 den 17.10.2005 klokka 12:12 (-0700) skreiv Lever, Charles:
> a customer recently pointed out that the rename(2) system call does not
> allow replacing directories, even if they are empty.  RFC1813 at least
> suggests that the server and protocol do allow directory replacement, as
> long as the target is empty.
>=20
> the culprit appears to be this check in nfs_rename()
>=20
>         if (S_ISDIR(new_inode->i_mode))
>                 goto out;
>=20
> which causes nfs_rename() to return -EBUSY if the target is a directory.
>=20
> is there a historical reason why the Linux NFS client does not allow
> directory replacement?  shouldn't the error code be -EISDIR for this
> case?

Yes, the error should be EISDIR. I'm not sure that I agree with your
assertion that rename failing is an NFS-only issue, though. The attached
testcase fails on both XFS and ext3 too with the error "Rename failed:
Is a directory".

Cheers,
  Trond


--=-JK6XxfoONTx7cV0aDYx1
Content-Disposition: inline; filename=main.c
Content-Type: text/x-csrc; name=main.c; charset=utf-8
Content-Transfer-Encoding: 7bit

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

#define FILENAME "gnurr"
#define DIRNAME "gnarg"

void die(char *errmsg)
{
	perror(errmsg);
	exit(1);
}

int main()
{
	int fd;
	int err;

	fd = open(FILENAME, O_CREAT|O_EXCL|O_RDWR, 0644);
	if (fd < 0)
		die("File creation failed");
	close(fd);
	err = mkdir(DIRNAME, 0700);
	if (err != 0)
		die("Directory creation failed");
	err = rename("gnurr", "gnarg");
	if (err != 0)
		die("Rename failed");
}

--=-JK6XxfoONTx7cV0aDYx1--



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
