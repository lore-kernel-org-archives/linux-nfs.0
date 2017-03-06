Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49401 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752584AbdCFDy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Mar 2017 22:54:58 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Date: Mon, 06 Mar 2017 14:54:49 +1100
Cc: Christoph Hellwig <hch@infradead.org>
Subject: Re: Confused by pnfs LAYOUTRETURN - seeking clarity.
In-Reply-To: <1488569105.2997.1.camel@poochiereds.net>
References: <87shmvnzh7.fsf@notabene.neil.brown.name> <1488569105.2997.1.camel@poochiereds.net>
Message-ID: <87r32bjbzq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Mar 03 2017, Jeff Layton wrote:

>
> There is one special case...
>
> When the server does a CB_LAYOUTRECALL, the client can reply with
> NFS4ERR_NOMATCHING_LAYOUT if it's not actively using the layout at the
> time. With that, the client isn't expected to do a LAYOUTRETURN.
>
> Any other status on the CB_LAYOUTRECALL however does require a
> LAYOUTRETURN.

Thanks, both to you and Christoph, for this pointer.
Things are starting to make sense.

However RFC5661 says under
   Operation 5: CB_LAYOUTRECALL - Recall Layout from Client

   While the client responds to the CB_LAYOUTRECALL immediately, the
   operation is not considered complete (i.e., considered pending) until
   all affected layouts are returned to the server via the LAYOUTRETURN
   operation.

which seems to strongly imply that a LAYOUTRETURN is expected.  No
alternative is listed.

Further:

    The NFS4ERR_NOMATCHING_LAYOUT error is only returned when the client
    does not hold layouts for the file or if the client does not have
    any overlapping layouts for the specification in the layout recall.

This is an *error* condition.   The client really does still hold
the layouts if it hasn't sent "LAYOUTRETURN".  The fact that the linux
client chooses to forget them and won't ever use them again isn't really
the same thing as "not hold[ing] layouts".

If I were a server author and I got NFS4ERR_NOMATCHING_LAYOUT for a
CB_LAYOUTRECALL where a I knew for certain that the client really did
have the layout, then I would probably feel justified in discarding all
state held by that confused client, and requiring to re-establish
everything (because I cannot trust anything any more).

So the Netapp filer is clearly doing the wrong thing, as we doesn't send
CB_LAYOUTRECALL.  But I'm far from convinced that Linux is doing the
right thing by replying NFS4ERR_NOMATCHING_LAYOUT.

However, I'm not going to try to "fix" anything here.  Hopefully we can
manage to stumble forward.

Thanks again,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli83YkACgkQOeye3VZi
gblLbA//ZcypUGfgu3gZ/6Oq5ChmqhyGLWET9MNswPOUNMmEG0cjq6hd7DEnBTU2
B/7m2514BPipHAd3sBN+7mhjRUL17OXb4l0bIDo57doB5aRpLlFcAgzdo3WlZ/sJ
07X93apGlhANurs+drv/9ba+6CVe98XkBA9ausYVMSigUSrXEfjU3IqIRjYabLff
D1WhYTslCDb96Sw55KMMIAQ70Km9xJQRvV23dBGISv4+dA6NAVjPfXKd3ip3Jmrk
859sHWZjjt6WYEiQndydeVF+FhWLfpD6mmq3U1AO209Q3/ejCY5isk2emllVY2uV
J6iXukfr7yYNiWOyJ5uzKF+KvZUDnmi8gEmYk6Cs+PhDQCcTzpAt/xBWAdXFW68F
PYgom2Q2c9rxt6tUtCnojJcR+NshQQx7fJS9UsHP07/aHSkZOA/RiPO7a1riD5J0
Y/tfoushG7QTZa5+hmAQPwhFpaHIYjZWrgJ5Ecof8v72j5pzWIRBJ9iPEJrpj0QH
mZ0zv6Ep3+dZod5bWV9P3twObSLAnzPM53+EZT0FX5ktHBH4DQOrKaq3JG/6+jsk
gNSn2jz49wRKcA1Tuy45uSjTqDgPTODTzn+qVurqi9BILdJc2QNPmElziiwtgJ0z
mz9MP0u5E+CRDOdFbqBq5+QfJ0RIQpI/WaP+6eJahIZPHWnXWFw=
=ZznJ
-----END PGP SIGNATURE-----
--=-=-=--
