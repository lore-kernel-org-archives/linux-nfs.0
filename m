Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45558 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751768AbdH1DyX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 27 Aug 2017 23:54:23 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 13:54:12 +1000
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 1/3] fs: cleanup to hide some details of delegation logic
In-Reply-To: <1503697958-6122-2-git-send-email-bfields@redhat.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-2-git-send-email-bfields@redhat.com>
Message-ID: <87efrwibyz.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Aug 25 2017, J. Bruce Fields wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
>
> Pull the checks for delegated_inode into break_deleg_wait() to simplify
> the callers a little.
>
> No change in behavior.
>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/namei.c         | 26 ++++++++++----------------
>  fs/open.c          | 16 ++++++----------
>  fs/utimes.c        |  8 +++-----
>  include/linux/fs.h | 12 +++++++-----
>  4 files changed, 26 insertions(+), 36 deletions(-)
>
> diff --git a/fs/namei.c b/fs/namei.c
> index ddb6a7c2b3d4..5a93be7b2c9c 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4048,11 +4048,9 @@ static long do_unlinkat(int dfd, const char __user *pathname)
>  	if (inode)
>  		iput(inode);	/* truncate the inode here */
>  	inode = NULL;
> -	if (delegated_inode) {
> -		error = break_deleg_wait(&delegated_inode);
> -		if (!error)
> -			goto retry_deleg;
> -	}
> +	error = break_deleg_wait(&delegated_inode, error);
> +	if (error == DELEG_RETRY)
> +		goto retry_deleg;

<mode=bikeshed>

I don't like the "DELEG_RETRY".  You are comparing it against an
'error', but it doesn't start with '-E', so I get confused (happens
often).

If this read:

     if (error > 0)
          goto retry_deleg;

it would be must more obvious to me what was happening.  Clearly the
return value isn't an error, and it isn't "success" either.  This is a
pattern I've seen elsewhere.

Alternately you could use "-EAGAIN", but I suspect there is a risk of
unwanted side-effects if you re-use and existing code.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmjk+cACgkQOeye3VZi
gblQAw//Sswv/WdGETz1Gs9kOrG9T3zpz9xTwWNHH3Rx1KB4geD/2qgNr3vWLad3
KfJIAjmCtamNFQ8taI1PyoKgufkrgjwXErXTCuCaCL7PLw1/wO7VQ+HnFjGen9NH
6pm5wKuLISSUfT4LT5qmx+eDX7+Bz/brmtk9hjnl0AFY5+r8L8l0caudvU3Qu9AD
QOZzcOnQZy+i36utiuvpbFG+svwm7jU4TFWEm5cvbEaaEyDbz2hQSlkYdZ3do6KZ
XlfwiSwqhE8j06OnQNEz6mpA6ikDpn8/6iWR2VdRzeQp73sacGvG3SMNpf9nOYen
da4kRa0WCkz7KX6pBSByfI2as1MUzt6ncsqNtn3wyuppnJLxieaghWCbmej8iKBp
N638vrzxXFNa96X0VGaCFX4saO5xY1hAnW92aygEz7QcUpxx7BgvmqvYgXuNATGE
mNetEjUMxppaArz+ZR/2EWEuiKNdmbkAPHf0yEaVcxv36k0OSAfZ93AMnq6tESlX
1e7ZqQduapMwP43OVkReDsVc8Mphcx5UKJ7gDjJUWxGLRyL2MnzXFTA84p0BS6ee
cKipz0XgSFzhyoKQYLBSl00DJBfznVMHb3XkhxhF+7jRVJTGmF1GU9VZs3X+g9eV
1xcSDWcGM7z68ibJZPpyaq4UljrQj8VPYJec1UuSaspD9/O0IOY=
=Novj
-----END PGP SIGNATURE-----
--=-=-=--
