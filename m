Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36021 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933912AbeFLWCL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Jun 2018 18:02:11 -0400
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        trondmy@hammerspace.com, Paul McKenney <paulmck@linux.vnet.ibm.com>
Date: Wed, 13 Jun 2018 08:01:58 +1000
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for 4.18
In-Reply-To: <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com> <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com> <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com> <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
Message-ID: <87vaanirzd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Jun 12 2018, Linus Torvalds wrote:

> Final note (for now) on this: I've merged the nfs code, but I really
> am obviously not happy with these crazy random ad-hoc
> cursor-not-cursor list games.
>
>                 Linus
Hi Linus,
 thanks for merging the code despite your reservations.

 Yes, we could create a generic rcu-list cursor.  I have given it some
 thought but didn't like the added complexity.  As there were existing
 objects in the list that could be used as a cursor, that seemed to me to
 be the better solution.

 As you say, and cursor would need to be allocated from a slab, not on
 the stack. We could use a SLAB_TYPESAFE_BY_RCU and not need to use rcu
 to delay the freeing.
 The lsb in the next pointer of the cursor would be 1 to indicate the
 cursor.

 Any iteration of the list would need to look out for this flag.
 When found it would need to skip over any cursors to the next
 non-cursor, then repeat the skip and make sure it found the same
 non-cursor.  This guards against the cursor moving while it is being
 examined.

 Any walk that needed to place a cursor would need to get an exclusive
 lock on the list from the start.  This is more locking overhead than
 just grabbing the lock to optimistically take a reference on the
 "current" item which I did in the NFS patch.  If the lists were
 normally short that might not be a problem. In this case the list can
 get quite long so the extra locking might be noticeable.

 Deleting objects from the list would need to be careful to preserve the
 flag bit, but that is the least difficult part.

 FYI I have an open proposal to improve the cursor used by rhashtable
 for rhashtable_walk - it sometimes needs to drop out of RCU in the
 middle of a bucket chain.  In that case the chain is normally short (16 is
 considered so long that the hash must have been compromised) and I
 propose an insertion sort to keep the addresses of objects in numerical
 order.  This way the address of the last object found can work as a stable
 cursor - we just search through the list until an object has a larger
 address.

 So my perspective is that while an rcu_cursor_list could be developed,
 I'm not sure it would always (or ever?) be the best solution to a
 given problem.
 I can turn these thoughts into a patch if you like and see what people
 think.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlsgQtcACgkQOeye3VZi
gbmz5RAAioOOcswDSiWP6oZywwC4s4LduFMli65WhiEeDoYFABnCVQi7fNzN2nGq
puLVJ6dcD6lDnF0Jx/S0IhxNUslK4kW4J+wP6Zyh1YXzykZjdWXuPlhF08x7WexL
8Vfnzr20zkd0EOOMLTb35gJ8G1Iwf08u8bveAKONNBWu+Hu5+oGMzVRdTo7zMSnJ
3ExeN8t/16aA+J6aSeyqju0qZcugi4pRvY6aNB5o7w3nHOxfeh6dL7kDjNQs/GS2
sjcPbZkamKyTUhgeAbUrRPIFYmFoKCoM5zpjtuDV1ULureoDuznoxUlzy6WcpfI/
dhgz2xsL3npf6xx2SwUmlziGC9Wv+me3dW22mJevdEdra/OioU14SUzFhct2dCOy
kN44rodufVxDcdMvcmRsQDfj1XamAscI5C06aToxDPrd6NNCTGJ/Ohn80Dc8rIz3
ZokLfp2taNHHW52EGbLRJHeALdD/miHcGBGTB9dp1Tg2lVH0vdkPtoNJ8hsDz3ba
OyI09swWOoYjpoiEmGZUAf7AfhGL2+IPFlmzcMonhXF7McVKGU6kc1DWwqbwkazg
eBv77JR1vLqnYDf7oD2QC3A8EDOMlYTvttB7vpzqFxMWcA+ZiVumXSoXYeTGImv/
xJoEch+7iIrDqRXwOi8HBXe8d/vKoTLMAlqNttr4ucbFArXs50k=
=jDil
-----END PGP SIGNATURE-----
--=-=-=--
