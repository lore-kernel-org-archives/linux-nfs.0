Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50738 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab1KNCTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 21:19:44 -0500
Date: Mon, 14 Nov 2011 13:19:29 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Rename dir on server can cause client to get ESTALE
Message-ID: <20111114131929.7b341444@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MgYtagTC2P559_TzXi0XDZl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MgYtagTC2P559_TzXi0XDZl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


hi,
  I've run into another issue that seems to related to FS_REVAL_DOT.

The script below makes the details precise, but the essence is that if I 'c=
d'
into a directory on the client, then rename it on the server, then it is
possible that the client will start getting ESTALE when accessing '.' - even
though the directory still exists.

The ESTALE is generated because nfs_lookup_revalidate fails on the dentry, =
so=20
complete_walk (in fs/namei.c) gets failure from d_revalidate() and so sets =
the
status to -ESTALE.

nfs_lookup_revalidate fails because when it repeats the lookup it sees a
different directory (as you will see the script creates a new directory with
the old name).

I think it only makes sense to do a ->lookup revalidate of the dentry at the
end of the path when there was a real non '.' or '..' name leading to the
dentry.  If we were just looking up '.', we want to revalidate the inode, b=
ut
not the dentry.

Unfortunately I cannot see how that distinction could be introduced into the
current path-walk code.

Any ideas?

Thanks,
NeilBrown


SERVER=3Deli     # name of server.  ssh access required.
DIR=3D/home      # directory on server to mount
MPOINT=3D/mnt    # location on client to mount it.
TMP=3D/neilb/tmp # path to scratch area in $DIR

sudo umount $MPOINT
sudo mount -o vers=3D3 $SERVER:$DIR $MPOINT

cd /
ssh $SERVER "rm -r $DIR$TMP/*dir*"
ssh $SERVER "mkdir $DIR$TMP/adir"
while [ ! -d $MPOINT$TMP/adir ];
do echo -n . ; sleep 2;
done
cd $MPOINT$TMP/adir || exit
echo "Entered directory"
ls -la > /dev/null
ssh $SERVER "cd $DIR$TMP; mv adir adir.moved"
echo "Moved directory on server"
ls -la > /dev/null
echo -n "Waiting for move to be visible on client"
while ls -la $MPOINT$TMP/adir >/dev/null 2>&1
do echo -n .=20
   sleep 3
   (cd / ; ssh $SERVER "cd $DIR$TMP; mkdir bdir ; rmdir bdir" )
done
echo
echo "Make replacement directory on server"
(cd / ; ssh $SERVER "cd $DIR$TMP; mkdir adir")
ls -la $MPOINT$TMP/adir
ls -la


--Sig_/MgYtagTC2P559_TzXi0XDZl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTsB6tjnsnt1WYoG5AQIqPg//fnuQ3UNYSZbVbmAECojx+lTwKGKWcldW
Rl7OPx+LGnq9mvWeVhP8Nsb7QU7T6JHsGrrRZlMPHmddG9EwOKWJV2WLo2MaM/D4
vwN9FfpTeQ13socpjyDQSnSZfYgzwNDYNrfy/hadbWk6lcR7AUoK1VnriizWUOT1
Wtq6ek8YTfaNENJmZ+iSPs9kqRrQ+MGVoIOvQg1lwny9leZhBBhgxD180pbhIJZs
vuCjv/44hWjMl/cqfvwzPBOwDikQzL4BaPvYhpyjNbfRpYbrfWb8HyhG7bYpkYKI
oPOKkZBxWtjNXxhpP+WHZ3tEzxyxIZUtVMRDTb8q8ud/07a1gtZ5k1pQXNh/gqPV
o8lwbAOuv4jkk7UfJpyFrSJ1g1zf+r5gTyLuC6RvcIISZo6rpk5geTXNUq017huG
Eh5i4g94Dj7m3/beh2jc7SQUv6a4Tt1CBib5Iec+fYG9TWVrwz9ksZZzjNm1k9Zx
eJRdC+Ygna4D+2VRhOU3EeegsT6BMz33ATdKU41LfZ9TYorOqWpcXN7dcp8zcpM7
bZHKMyGXhxkl569glWSFlc8V4AInZoxWcKloLYlNmEpouwt+a4llJFbRhkwzllEW
zMxwabQBh+UMzgZSQuvE1zijhAoqlM+DTS/J9ueP6WzWIz111Lexa/EQMSl9qiv5
jNRohrq8pzY=
=dSTB
-----END PGP SIGNATURE-----

--Sig_/MgYtagTC2P559_TzXi0XDZl--
