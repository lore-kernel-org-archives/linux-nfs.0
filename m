Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57460 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753818AbdLMCUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Dec 2017 21:20:35 -0500
From: NeilBrown <neilb@suse.com>
To: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 13 Dec 2017 13:20:22 +1100
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH 1/4] fs/notify: fdinfo can report unsupported file handles.
In-Reply-To: <CAOQ4uxgYeqFtj=uVFDB84zUDu5-QrQLbH2DwgsJrXGtb2Fr9sA@mail.gmail.com>
References: <151297214390.7818.7216826079527521005.stgit@noble> <151297224512.7818.18333908109878259066.stgit@noble> <CAOQ4uxj9VhiCtPSt+Lyv8qyUz2hJ=VQzSYCKZ_6yqvs2q7y6Qw@mail.gmail.com> <87609dort0.fsf@notabene.neil.brown.name> <CAOQ4uxgYeqFtj=uVFDB84zUDu5-QrQLbH2DwgsJrXGtb2Fr9sA@mail.gmail.com>
Message-ID: <87o9n3nzbt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Dec 12 2017, Amir Goldstein wrote:

> On Mon, Dec 11, 2017 at 11:52 PM, NeilBrown <neilb@suse.com> wrote:
>> On Mon, Dec 11 2017, Amir Goldstein wrote:
>>
>>> On Mon, Dec 11, 2017 at 8:04 AM, NeilBrown <neilb@suse.com> wrote:
>>>> If a filesystem does not set sb->s_export_op, then it
>>>> does not support filehandles and export_fs_encode_fh()
>>>> and exportfs_encode_inode_fh() should not be called.
>>>> They will use export_encode_fh() is which is a default
>>>> that uses inode number generation number, but in general
>>>> they may not be stable.
>>>>
>>>> So change exportfs_encode_inode_fh() to return FILEID_INVALID
>>>> if called on an unsupported Filesystem.  Currently only
>>>> notify/fdinfo can do that.
>>>>
>>>
>>> I wish you would leave this check to the caller, maybe add a helper
>>> exportfs_can_decode_fh() for callers to use.
>>>
>>> Although there are no current uses for it in-tree, there is value in
>>> being able to encode a unique file handle even when it cannot be
>>> decoded back to an open file.
>>>
>>> I am using this property in my fanotify super block watch patches,
>>> where the object identifier on the event is an encoded file handle
>>> of the object, which delegates tracking filesystem objects to
>>> userspace and prevents fanotify from keeping elevated refcounts
>>> on inodes and dentries.
>>>
>>> There are quite a few userspace tools out there that are checking
>>> that st_ino hasn't changed on a file between non atomic operations.
>>> Those tools (or others) could benefit from a unique file handle if
>>> we ever decide to provide a relaxed version of name_to_handle_at().
>>
>> If the filesystem doesn't define ->s_export_op, then you really cannot
>> trust anything beyond the inode number (and maybe not even that), and
>> the inode number is already easily available.
>> What actual value do you think you get from this pretend-file-handle
>> on filesystems that don't support file handles?
>>
>
> Sorry, I misread your patch. In my mind I thought you wanted to
> eliminate the default export_encode_fh if there was no fh_to_dentry
> operation like do_sys_name_to_handle() does. Just in my head...

I see... I would have said that fh_to_dentry was mandatory if
s_export_op was set, and Documentation/filesystems/nfs/Exporting agrees
with me.  But I do see that sys_name_to_handle() and nfsd explicitly
test for it as well as for s_export_op.

It appears that cifs sets s_export_op, but doesn't provide fh_to_dentry,
and it is unique in this.
But the CIFS_NFSD_EXPORT config option is marked as BROKEN, so
that probably doesn't matter.

So for all current filesystems, filehandles are only reported if they
are usable for dentry lookup...

>
> FWIW, according to Pavel, if fdinfo would not export file handle
> in case !fh_to_dentry op would probably be desirable, because
> criu has no need for file handles that cannot be decoded.

Yes, it was good to have that confirmed - thanks for getting that
checked.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlowjmcACgkQOeye3VZi
gbkrMBAAob03SeL1YXOqfiNAYRCedVRqbH/rJ3pD/Gm24HLxTsCpnlGdEPQFvn85
LiwU2hwfbj5I1HEU2xUfyfoT07COv0okdYhzMvX8GNB0o1JKIIGkwmJTeJuSIC0v
yhZxHX+JglouaDoohcF/wLyOjsE+Fx0lD9qp3xWtOyIuhg02WDTtiaR7RG6i2mEl
eOiFrcoBkqlsQqC2RvWITVsJ1ekDQYg84z8B47yzjMlaJn5mIc7KXIQeKaUEtI9Q
s2YR6ZmMkpK/0wHZxO/1sKkdz58sHhReRMr93d2d/0I7fEAleXGvbhxm1sJtdIwz
zJ7rc3ldN0KH+csMXOme5V+QLudpoe8ZryR5qd0gMP2QP8ygvdVi2ELKDdKEFMb7
5TJ6AIbUyKheTtS+WRpJXfUM24dJztmjhk1/9fNapAfMnWd9yaJfmuATZyRD4vEk
k7VW4rsJFJxRHQ50GoSeuQFZM4+1us2Fb0m4GjuffZSirJJbD277gIABry4G968s
Cx6CGfmXgoDa/Hrxbv9G6qI07jCWrSA5+RPKcOmdLkOLM082b8EVtOfh3kn8bDOz
8hHlvGdEEbwQZU1DptgUnT9sIf/KucHih0HkqjmSl+gAEyJSorcJjaX49qr620mX
b/ECzWJIF9hcBe6DBTEdVaN2kyvvEzN+4YaL8KTMGLe/iETKFKs=
=qirn
-----END PGP SIGNATURE-----
--=-=-=--
