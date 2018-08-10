Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55400 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726961AbeHJD5O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Aug 2018 23:57:14 -0400
From: NeilBrown <neilb@suse.com>
To: Nelson Elhage <nelhage@nelhage.com>, Christoph Hellwig <hch@lst.de>
Date: Fri, 10 Aug 2018 11:29:33 +1000
Cc: linux-nfs@vger.kernel.org, Bruce Fields <bfields@fieldses.org>,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com> <20160321144349.GA12804@lst.de> <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com>
Message-ID: <874lg3roua.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Mar 21 2016, Nelson Elhage wrote:

> That's correct. The other detail that seems to be important is that
> the user making the call must be different from the user owning the
> file. We've also been using user remapping on the server, so that
> non-xattr calls succeed in that configuration.
>
> The reproducer James added in the bugzilla is:
>
> (on machine with IP address 10.1.1.1)
> sudo mkdir /nfs_test
> sudo useradd -u 10000 test_user
> sudo chown test_user /nfs_test
> echo "/nfs_test 10.1.1.2(rw,all_squash,anonuid=10000)" | sudo tee -a
> /etc/exports
> sudo exportfs -a
>
> (on machine with IP address 10.1.1.2)
> sudo mkdir /nfs_test
> sudo mount -t nfs -o vers=3,noacl 10.1.1.1:/nfs_test /nfs_test
> touch /nfs_test/foo
> install -m 755 /nfs_test/foo /nfs_test/bar

Did anything ever happen about this?
I have a customer with a similar problem (in 4.4) but I cannot see any
evidence of fixes landing in mainline.

Problem happens with you have uid mapping on the server
(e.g. anonuid=10000 as above) and a user with a different uid on the
client attempts setacl on a file with that user.
As anon is mapped to the owner of the file, setacl should be allowed.
However set_posix_acl() calls inode_owner_or_capable() which checks if
the client-side uid matches the visible inode->i_uid - they don't.

Testing i_uid on the client is always incorrect for permission checking
with NFS - the client should always ask the server, either with ACCESS
or, in this case, by simply attempting the operation.

Any suggestions how best to fix this?
- We could move the responsibility for permission checking into
  i_op->set_acl, but that would be a large change and might make it too
  easy for other filesystems to get it wrong.
- we could have some sort of flag asking set_posix_acl(), but that's
  rather clumsy.... maybe if i_op->set_acl_check_perm use that without
  testing ownership first??
- we could copy
    posic_acl_xattr_{get,set,list} into nfs together with functions
    they call, modify set_posix_acl() to not test ownership,
    and provide a local 'struct xattr_handler' structure for NFS.

I don't really like any of those suggestions.  Can someone else do any
better?

Thanks,
NeilBrown


>
> - Nelson
>
> On Mon, Mar 21, 2016 at 7:43 AM Christoph Hellwig <hch@lst.de> wrote:
>>
>> Hi Nelson,
>>
>> this was indeed most likely caused by my patch.  Just to narrow things
>> down can your clarify that the scenarious is that you have CONFIG_NFS_V3
>> set on your client, you're talking to a server not supporting ACLs
>> at all, and a tool trying to set an ACL is getting the wrong return
>> value?  If so I should be able to reproduce this locally.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlts6n0ACgkQOeye3VZi
gblGuA//VvWVInVZvBfjQkVHhXTFJku0IItL5W2vMaH3yeZo3jgV50SgymEf88NF
zj6VTnY1dcTtAXSLbsVquppddz/fnKY+Q/pcRoAFcDHlFmcuOCVfyt1sv3S17+8D
8jwmk5MaIcBLadrfkm5/6sqF1hydLrW298cvP/IstrhVao1B7NYh8Le0o8WELAcI
mq6lKC2mmSAgCzjGaIB/V7Un+UaIq9reG4HZ+Al+XIKQZoLNygYuaJLird4c2NK3
H5PNgpvVyey9dEpd29dOhdNXEQrq2lLZ3AOL856dkuc2gWFPASfsKBiITsf9dnUB
9FMSPrvuHPkWAHxsdyheUeDC2C4DMcn+4s3f7nbPDNWHNjAOURGbTPpcK+68++8A
Q10zmnhlOBLoQCzr39PulntOH0WquT8F7o/QpZLGyfHNJ9rxFtbXdN/f5LZuK8R4
t6aFiBEioJv0kLGAA1ysnblMyA97dXQhUcLefhVnzSW3/9sikDaahfTYOOARj1Mq
FRpFwMdP/tpkhgeCLHWhhP29R5aqkuFCJCkIbrTZXxauBIgR6Tja5NPd+WyV7LnT
mjQ1HRHTId4Jaf+SVyP0DDoi59cgemhqwCTY/8gJJ/BK9zmNl3suZkxV3/TsqQqN
MGwEth9QEKxzDI3GTXKfOoXiNBzn9dzqNoYwBGpUQ19JMVsMAeU=
=NJno
-----END PGP SIGNATURE-----
--=-=-=--
