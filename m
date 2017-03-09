Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35456 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751355AbdCIHed (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 02:34:33 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id A713CAAC7
        for <linux-nfs@vger.kernel.org>; Thu,  9 Mar 2017 04:46:55 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
Date: Thu, 09 Mar 2017 15:46:49 +1100
Subject: Re: A NFS mount can still write to the server after 'umount' has completed.
In-Reply-To: <871su7i0iw.fsf@notabene.neil.brown.name>
References: <871su7i0iw.fsf@notabene.neil.brown.name>
Message-ID: <87y3wfgipy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Mar 09 2017, NeilBrown wrote:

> I've been chasing down a problem where a customer has a localhost mount,
> and the sequence
>   unmount -at nfs,nfs4
>   stop nfsserver
>   sync
>
> hangs on the sync.  The 'sync' is trying to write to the NFS filesystem
> that has just been unmounted.
> I have duplicated the problem on a current mainline kernel.
>
> There are two important facts that lead to the explanation of this.
> 1/ whenever a 'struct file' is open, an s_active reference is held on
>    the superblock, via "open_context" calling nfs_sb_active().
>    This doesn't prevent "unmount" from succeeding (i.e. EBUSY isn't
>    returned), but does prevent the actual unmount from happening
>    (->kill_sb() isn't called).
> 2/ When a memory mapping of a file is torn down, the file is
>    "released", causing the context to be discarded and the sb_active
>    reference released, but unlike close(2), file_operations->flush()
>    is not called.

I realised that there is another piece of the puzzle.
When a page is marked dirty (e.g. nfs_vm_page_mkwrite),
 nfs_updatepage() -> nfs_writepage_setup()
creates a 'struct nfs_page' request which holds a reference to
the open context, which in turn holds an active reference to the
superblock.
So as long as there are dirty pages, the superblock will not go
inactive.  All the rest still holds.

NeilBrown


>
> Consequently, if you:
>  open an NFS file
>  mmap some pages PROT_WRITE
>  close the file
>  modify the pages
>  unmap the pages
>  unmount the filesystem
>
> the filesystem will remain active, and the pages will remain dirty.
> If you then make the nfs server unavailable - e.g. stop it, or tear down
> the network connection - and then call 'sync', the sync will hang.
>
> This is surprising, at the least :-)
>
> I have two ideas how it might be fixed.
>
> One is to call nfs_file_flush() from within nfs_file_release().
> This is probably simplest (and appears to work).
>
> The other is to add a ".close" to nfs_file_vm_ops.  This could trigger a
> (partial) flush whenever a page is unmapped.  As closing an NFS file
> always triggers a flush, it seems reasonable that unmapping a page
> would trigger a flush of that page.
>
> Thoughts?
>
> Thanks,
> NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljA3jkACgkQOeye3VZi
gblYEg/+Jx5u48NyGXJxcznJotFhQIiLEplI2KRnbpmA7p+eR8YHMRzKVGomU0FO
9vlXZL2UDfse61Y7XPsKnQg9PtWu/p3YkmvHTSEg/RwGQsum7nNl2fK5DaE3iQTw
2EFIGFOwLHY1+P2Huai8I1pQ4tpS7NGhdFvYK8RnLwMMmWtA345SBa2k2mEgo3ey
4D1gtStOjIs58o9ji3OsVyWhTmGDKcTL+NBVlwLqfsjvCTUn6MZcPS8TS/t7lOfx
dObgBrsdCELOR9FRp79eW8OB7RjBTFKjM1i2vZNBE4uwgLqsvgTZYoTS7+6EwHaq
aQjNi+5hmsVdsHhld/Wsd5QRMDBvn/ATjIVbrbH4t8tdK+lyTOFIVIcHmDZzlg9p
ofhYqdrosuUd0VHDib4EHtUmtVHdOUWmrXxIA4ykrCqMmQujiqN0d2IKZBd5H2BR
KhcVXS5aVDyF1kERumvG91g7xGIHY+ApIuhcGBjVXgDu0kZCGidqnZ+3LospxpWx
5UMjnBAWvfkLT6pAmUIWdDot7xvmWy3M+NIqJBoUsbgAYepDKVowjpkQXtS9PyRw
MGgUWdvJbcguiam5wC/k+tvKxeCOdoIr24AnbgWIvXWGFbS6Vkcd2rDfz/wHkPoe
zs1hD/6aQV3jseMoLh/v2Yg4MPqZHVVhJ0ANEmIVkW6IqnUZs7k=
=LOJs
-----END PGP SIGNATURE-----
--=-=-=--
