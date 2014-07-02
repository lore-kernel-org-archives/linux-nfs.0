Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44414 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965214AbaGBBFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2014 21:05:34 -0400
Date: Wed, 2 Jul 2014 11:05:25 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NFSv4 open sequencing can lead to incorrect ESTALE
Message-ID: <20140702110525.3b3d0f8d@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/6FOZfvfxke2GOXXX6FxiuPf"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/6FOZfvfxke2GOXXX6FxiuPf
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 The bash script below demonstrates a problem with NFSv4 - maybe two.
 I'm testing on 3.16-rc2.

 It mounts a local filesystem via NFS.  The main thread then replaces
 a particular file on the local file system and then accesses it via NFS,
 checking that the contents are correct.  It does this repeatedly.

 In parallel a number of threads repeated open/close the same file (using
 'grep' rather than 'cat' so tracing in the kernel can see which is which).

 With NFSv4, none of these should ever get ESTALE.  The server holds the
 file open while the client has it open so even if it is unlinked in the
 local filesystem, the client will still be able to access it.
 Yet we do get ESTALE errors.

 These are caused by the may_open() call in do_last().
 may_open() calls inode_permission() which calls nfs_permission() which
 performs an ACCESS call over NFS, which can get ESTALE.  This error will
 stop do_last() from calling finish_open() which, in the NFSv4 case, does t=
he
 final lookup and would for this test find the correct, non-stale, inode.

 When may_open() and then do_last() return ESTALE, do_filp_open() will call
 path_openat() again, this time with LOOKUP_REVAL, but that doesn't help.
 nfs_permission only gets the inode and so cannot d_drop the dentry or
 otherwise trigger a reval.

 I added a d_drop() to may_open() when inode_permission() returns ESTALE and
 the symptom went away, but I doubt that is the right thing to do.
 For NFSv4 I think it is really best to leave all the work to the 'open' ca=
ll
 and not perform any access tests before hand.  All the access tests should
 happen inside the open call once the server knows that the file is 'open'.

 I have no suggestion for how to fix this properly.


 Once that bug is fixed, the script still shows unexpected behaviour.  It
 will eventually report that the file seen over NFS has the old content
 instead of the new content.

 This happens because the file (which has been unlinked on the server via a
 rename) is still open by one of the background threads and so
 can_open_cached() reports that "cat" doesn't need to actually open the file
 - it can re-use the open that the 'grep' has.
 This seems a little odd.  It is a bit like treating an active  'open' of a
 file as a mini-delegation, you don't need to open it again.  However if it
 was a real delegation, then when it was unlinked on the server the
 delegation would be lost.
 I tried running with "lookupcache=3Dnone" but I still get the same errors.
 That certainly seems like an error.  With lookupcache=3Dnone, opening a fi=
le
 should check the name on the server, not assume that the name cached on the
 client is correct.  But that isn't what happens.

 I have no idea how to fix this one either.  I'm not even 100% sure which b=
it
 is the bug, but something definitely seems wrong.
 I changed can_open_cached() to always return 0 and the problem went away,
 but again I don't think that is a correct fix.

Thanks,
NeilBrown


cnt=3D${1-10000}
local=3D${2-/export}
nfs=3D${3-/mnt}
max_errs=3D${4-1}

echo "using: $cnt $local $nfs $max_errs"
mount -o vers=3D4,lookupcache=3Dnone localhost:$local $nfs || { echo mount =
failed ; exit 1; }

rm -f $nfs/afile
touch $nfs/afile

for i in {1..5}; do    while [ -f $nfs/afile ]; do grep . $nfs/afile > /dev=
/null 2>&1 ; done &  done

i=3D0
err=3D0
while [ $i -lt $cnt ]; do
  mydate=3D$(date +%s.%N)
  want=3D"$i $mydate"
  echo  $want > $local/bfile
  mv $local/bfile $local/afile
  have=3D`cat $nfs/afile`
  if [ "$want" =3D=3D "$have" ]; then
     echo -n -e "$want\r"
  else
     echo fail > /dev/kmsg
     echo "Wanted $want have $have."
     for x in {1..1000}; do
        sleep 0.1
        grep "$mydate" $nfs/afile && { echo File now correct; break;}
     done
     let err=3D$err+1
     if [ $err -ge $max_errs ]; then
         echo
         echo $err failures after $i attempts
         rm $local/afile
         umount $nfs
         exit 1
     fi
  fi
  let i=3D$i+1
done
rm $local/afile
echo
echo $err failures in $i attempts
sleep 2
umount $nfs
exit 0

--Sig_/6FOZfvfxke2GOXXX6FxiuPf
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU7Na1Tnsnt1WYoG5AQKbnBAAsrTWLD6AQayy1+H1aGJVmgy+QhQGlO4o
fanhhmcjWungmjm9joETEctdHxRy8H/aWnvw5EtLPWjaRYlUGWP3DiraeB39voOS
Hm2wk7Y0636fLeo5mZsKL2SW62bP+hYm9B5njqFTJhJJn7p1J4YB1Q3mNYh7sDET
f0addEOC8kYa45fiS9e0s+pvsI/DxCSN9RgUo2+6wIDLa+CQvHIRaXBXsYPwdIhW
rwVHJrJ5VD1p2STUx2I868X8HOOJewOyE8/GvA2hAQqOQ9MA1KhJBqt972FP4qEg
FApDBu8bscNUEEHVQHpSP0cvRjxKVlxVBO5VFpk5so/63rDd6OaHMjP7SJJuQvME
rv6CWCdlDsWKPOuzSPg0VoEF5po95sBAEgLshjXP2rJsJn8Wuf4NSLWc13GmWlMp
z0WnCbs1gjqfTdnhwsr4p7Lp230A7RO33vCOz6VxygOU50C4yaY49zdLXg3+70C8
/5NWrJxFQosNIBaqV/7jOVu/GSofXe8KtZJ6SvwvBWC61Z3NP79XMw3gEwH++q/E
8PwnKgT3GmPGPLcnshxQ1ghmWi4A1NiqdOalfOYnvqlf/VhriQbU4YJVTgDI63FH
qY7c0gEytk/Cmt0XB8m9Pgz6qEzQg2Pkk/GG6R06OSMHBWFSexn1xPHOji1yP+Ro
d651QccjdJI=
=y7lj
-----END PGP SIGNATURE-----

--Sig_/6FOZfvfxke2GOXXX6FxiuPf--
