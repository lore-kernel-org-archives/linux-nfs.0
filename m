Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50113 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934003AbcKJWcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 17:32:15 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>
Date: Fri, 11 Nov 2016 09:32:07 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about nfsdcltrack --storagedir
In-Reply-To: <8B417571-FAA9-4793-AE5F-F71BCDF7ADD5@oracle.com>
References: <87k2cdmi26.fsf@notabene.neil.brown.name> <1478692626.2394.9.camel@redhat.com> <877f8c9pku.fsf@notabene.neil.brown.name> <1478739358.2442.1.camel@redhat.com> <8B417571-FAA9-4793-AE5F-F71BCDF7ADD5@oracle.com>
Message-ID: <87oa1nklug.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11 2016, Chuck Lever wrote:

>>=20
>> No objection here, especially if we make it so that we have existing
>> behavior when there is no config file. nfs-utils even has some config
>> file parsing routines now in support/nfs that should be sufficient.
>
> Just a general thought:
>
> It's fine to store the configuration data under /etc, but for new
> administrative interfaces, please create a command line UI which
> is used to edit said configuration data. This makes it much easier
> for users to script administrative changes, to build GUIs around,
> and for our Q/A teams to construct automated tests.

If that is an important concern (and I don't disagree) then I would
suggest dropping the idea of a config file with sections and just have a
file with simple (case sensitive) "name=3Dvalue" assignments.  Then sed
can be used to modify the file.

Or.... just use git to modify the config file.

  sudo git config --file /etc/idmapd.conf mapping.nobody-user neilb

did what I expected it to do :-)

I would lean towards a flat config file myself, but nfs-utils already
has code for structured config files, and that code ignores settings
before the first section.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYJPVoAAoJEDnsnt1WYoG5oGwQAKlL4BVRCpNZaM58DcJ98+8E
iWNKSFVsRv7AOGfET0oxQYsrQZMdfLWNQtpM/Wgi06WJGNN7q3vK7zu97xxKtylm
RUyKINqjJitB5R4VBOjQa4sadVahAZ+8six71E9751Zr5bfHM1b/SYkyAdyF2O+5
oKbIJxG0f1kCLB0lPB6GDL7RaUsnb0JZZ5UQZ9XYmvQ+yhElrS0jforlI7w3OVuY
smSPiVLTucAk0dCEYPrQYtpUzxL58Fg1W+kfmwaF7xSIRkoXbMbONCW9UX8LRtGi
cqkdwL4GJ5vIZpEgp9FcvLFwXXHYuIxRaAAlQc1XDJNaAhPRE4o2h2gQfrv0p1jj
khm2+RJztvwASZzqjQtJdtCOxZ7LIIZJOjzupH849C62l5L4djf2b5+2aIHZ4E3t
IB5lgEvphaCfyiJTDs3E7Fg9WudsU9Ii4bcvJ4/yFWXgahS4Suhw97TX5RN9p9Vm
GJdLyoe9Vn/ffbDHJhHJ/4WkzwKibZ2qqaODORwN4mZs2eKIbmelQhyFSdFDAu6/
43upNV2aC+m4DkNP85TSC09lX/EvMfUyfRa0SFmqyheIWeIPtuZOG6L8aYO+OSyq
pqw+wcuxJzqxMt7uxvhWcKYmsUgE59D7tK0DgYkK8vf0M5XyPbKfaB9Iq/rVsK7t
uuW+n5GgeacOS7/jWLJc
=ANZI
-----END PGP SIGNATURE-----
--=-=-=--
