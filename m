Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42125 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbaE2Gpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 02:45:30 -0400
Date: Thu, 29 May 2014 16:45:21 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Live lock in silly-rename.
Message-ID: <20140529164521.02324559@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/eqgp=7qBk9htDbcp6dae/vq"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/eqgp=7qBk9htDbcp6dae/vq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


The program below (provided by a customer) demonstrates a livelock that can
trigger in NFS.

"/mnt" should be an NFSv4 mount from a server which will hand out READ
delegations (e.g. the Linux NFS server) and should contain a subdirectory
"/mnt/data".

The program forks off some worker threads which poll a particular file in
that directory until it disappears.  Then each worker will exit.
The main program waits a few seconds and then unlinks the file.

The number of threads can be set with the first arg (4 is good). The number=
 of
seconds with the second.  Both have useful defaults.

The unlink should happen promptly and then all the workers should  exit.  B=
ut
they don't.

What happens is that between when the "unlink" returns the delegation that =
it
will inevitably have due to all those "open"s, and when it performs the
required silly-rename (because some thread will have the file open), some
other thread opens the file and gets a delegation.
So the NFSv4 RENAME returns NFS4ERR_DELAY while it tries to reclaim the
delegation.  15 seconds later the rename will be retried, but there will st=
ill
(or again) be an active delegation.  So the pattern repeats indefinitely.
All this time the i_mutex on the directory and file are held so "ls" on the
directory will also hang.

As an interesting twist, if you remove the file on the server, the main
process will duly notice when it next tries to rename it, and so will exit.
The clients will continue to successfully open and close the file, even
though "ls -l" shows that it doesn't exist.
If you then rm the file on the client, it will tell you that it doesn't
exist, and the workers will suddenly notice that too.

I haven't really looked into the cause of this second issue, but I can work
around the original problem with the patch below.  It effectively serialised
'open' with 'unlink' (and with anything else that grabs the file's mutex).

I think some sort of serialisation is needed.  I don't know whether i_mutex
is suitable or if we should find (or make) some other locks.

Thoughts?

Thanks,
NeilBrown

Patch:

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8de3407e0360..96108f88d3f9 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -33,6 +33,10 @@ nfs4_file_open(struct inode *inode, struct file *filp)
=20
 	dprintk("NFS: open file(%pd2)\n", dentry);
=20
+	// hack - if being unlinked, pause for it to complete
+	mutex_lock(&inode->i_mutex);
+	mutex_unlock(&inode->i_mutex);
+
 	if ((openflags & O_ACCMODE) =3D=3D 3)
 		openflags--;
=20


Program:
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>


// nfsv4 mount point /mnt
const char check[] =3D "/mnt/data/checkTST";
const char data[] =3D "/mnt/data/dummy.data";

int num_client =3D 4;
int wait_sec   =3D 3;

// call open/close in endless loop until open fails
void client (void)
{
    for (;;)
    {
        int f =3D open (check, O_RDONLY);

        if (f =3D=3D -1)
        {
            printf ("client: done\n");
            _exit(0);
        }
        close (f);
    }
}

int main (int argc, char **argv)
{
    int i, fd;
    FILE *f_dummy;

    if (argc > 1)
        num_client =3D atoi (argv[1]);

    if (argc > 2)
        wait_sec =3D atoi (argv[2]);

    fd =3D open (check, O_RDWR|O_CREAT, S_IRWXU);

    if (fd =3D=3D -1)
    {
        perror ("open failed:\n");
        _exit (1);
    }

    close (fd);

    for (i=3D0; i<num_client; i++)
    {
        // fork childs to poll the 'checkTST' file
        pid_t p =3D fork ();
        if (p=3D=3D0)
            client();
        else if (p=3D=3D-1)
        {
            perror ("fork failed");
            _exit (1);
        }
    }

      // parent process
      // - wait a few seconds and unlink 'checkTST' file
      // - all childs are polling the 'checkTST' and should
      //   end now
      sleep (wait_sec);
      unlink (check);
      printf ("server: done\n");
}

--Sig_/eqgp=7qBk9htDbcp6dae/vq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4bXgTnsnt1WYoG5AQLyKw/+Imh6y2mUa7wQFmxhSKNWudML9hHQdTp8
99iMii61Htg1BT2CHmmqPFEPZn9XtihQtrj0Z+fa9pDOo9QSXzGh4d8Ll52OI9X3
iXmWwwSDcaVvaPmhAXVER4oNyOJrKhznsN869GfmHxUIstj6gPvDVz14+lfQlzKJ
s4VGVtKToE894dwcfQvNeNU/kQHM6Bl8J4PBPJNFLaXDWrIZmKiR9E28hTDswLfC
iwOd4Do+0db7j8o+MBpICB7D8hO3LBoOql0sb2k075MaDLSCmKppNgSe4FkB7S0b
BEx1V3AeKrX+JFzAXetO7oWoqLHQS7XxWDw1B4cgk/F8t1q+blf8F2oKylLstZHU
mSp3Oo/pM/CnHNRLw3JsshLyvyCb9D/ssxb/VGreoEHynuNM+YgyLnu/qTlkcbfJ
uiSPHaqevJA5xvRj/7WiZRFuoyYyGKH7E6IAtcE032dEbHBgdb6QWPpMa5MYvyq0
abrR3uZ1WeSgsZyQSivbXJvteVIePIIt9/YQqN5NC0lmwWQIZ8/CrxF2iF5DRQKI
Znb5HTZ0RVn15Ngh0VcLAEmsCXxYw5dysbEJNN1LHssILnTujAsI2zFckyA8vHQw
Gf5jA9f95BLabSb50uJSjzNhkZcJ5vNnkntnjyppAuO4f3sUZolA4zi+JQSf4/1Z
uq0QdpQtBVk=
=3ECS
-----END PGP SIGNATURE-----

--Sig_/eqgp=7qBk9htDbcp6dae/vq--
