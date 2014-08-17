Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48930 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbaHQVPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Aug 2014 17:15:14 -0400
Date: Mon, 18 Aug 2014 07:14:57 +1000
From: NeilBrown <neilb@suse.de>
To: Tejun Heo <tj@kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFS: state manager thread must stay running.
Message-ID: <20140818071457.4b345727@notabene.brown>
In-Reply-To: <20140817131156.GB7679@mtj.dyndns.org>
References: <20140813140831.22f3e9c7@notabene.brown>
	<20140817131156.GB7679@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/rsoZLu=iu7TbNGn.iiClfh9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/rsoZLu=iu7TbNGn.iiClfh9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 17 Aug 2014 09:11:56 -0400 Tejun Heo <tj@kernel.org> wrote:

> Hello, Neil.
>=20
> On Wed, Aug 13, 2014 at 02:08:31PM +1000, NeilBrown wrote:
> > There are two interesting requirements for the manager thread:
> > 1/ It must allow SIGKILL, which can abort NFS transactions to
> >    a dead server.
> > 2/ It may continue running after the filesystem is unmounted,
> >    until the server recovers or the thread is SIGKILLed
>=20
> Out of curiosity, why is SIGKILL handling necessary at all?  Can't nfs
> just keep the manager running while any mount is active?

It does.  The manage will even continue after there are no mounts active if
it is blocked on a non-responding server.

If there is an outstanding RPC request to a non-responsive server
then the only way to abort that request is to send SIGKILL to the thread
which is waiting for the request.
So if we want things to clean up properly on shutdown it seems best for a
sigkill to be able to abort that thread.

It is quite likely that a deep re-write of various details could simplify
this.   There seems little point in the manager continuing after the lease
timeout has expired for example.  So there could be better ways to clean up.
However I think we probably do want the state manager to continue trying at
least until the lease time expires, so we cannot clean up the thread at
unmount time - it needs to persist at least a little while.

It is also possible that I'm missing some important details.  I really just
wanted to avoid the possible memory deadlock without breaking anything that
I didn't completely understand..  The proposed patch is the best I could do.

Thanks,
NeilBrown

--Sig_/rsoZLu=iu7TbNGn.iiClfh9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/EbVznsnt1WYoG5AQLEmA/7BpHY5m8fzlRNMvjmopkVMMjVUmRGlMfG
ErIVAIvq/Xyc450P3yu3180SAk/57iPMrbAN984Q87ZXpdUntQQxRZAXyE7E6RoS
K+GuxEJXzozZDjP2gLxvzWT3tn3wmra4bnJzP1+6oWshyhE9kbGJLClT7CwQWeVP
SWrQ0lMdHKIhYd+6l4hCbJQGgeXV2D33UC5uvIN+XEQPxiSx+wPXW56kV0t1Bs+a
vHG24nCjNyH1W2Ge5YmefM/7sL0tU/jKwPclJ/1os68cJeYpAiNkazv+Sw1kRlHJ
WSgfnvoKMRGecUAzICxO7Xbpj7HLQojY7vypg0rEslkA4dAuZcuA8JaYzaGJkBWO
cfZ+KeQxozTS44IRuobQkIkh8hEC+IENSj9oBkhy9Odaj1XXQV2oiCQS2pqLfpBY
AH38ICS7Qx4/RCe057B47EUDdI37PwMXW8cm93G38bs71ykLvd3iCD3mO4ZkY+Va
bYsVZFFF0vY5aAbACe1Up5nTQedjwW2xgDHmvmQVWWN/BVzY399lpE7jJijW65UD
9T0OOUtLlzQmdv/8uBdHTA7cSPdfyaPP7whorYLsBk2DqJOLljD02LSZbXCer+zs
95RNEVtZFVY5efeuegNiIi8B99+L2OkWKgmeGBU/4sRNY2hrwlQvn2Hk9lA4aH5o
8gweTAPjnKI=
=jHim
-----END PGP SIGNATURE-----

--Sig_/rsoZLu=iu7TbNGn.iiClfh9--
