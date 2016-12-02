Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39192 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932750AbcLBAPT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 19:15:19 -0500
From: NeilBrown <neilb@suse.com>
To: Joachim Banzhaf <joachim.banzhaf@googlemail.com>,
        linux-nfs@vger.kernel.org
Date: Fri, 02 Dec 2016 11:14:38 +1100
Cc: "joachim.banzhaf" <joachim.banzhaf@googlemail.com>
Subject: Re: rpcbind allowed port range on linux
In-Reply-To: <CABW3MLd5Bo-xBtLqtB4e-pD2hCYAuRaBBsqBFTiws5-HohjPTw@mail.gmail.com>
References: <CABW3MLd5Bo-xBtLqtB4e-pD2hCYAuRaBBsqBFTiws5-HohjPTw@mail.gmail.com>
Message-ID: <87h96n6vbl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 02 2016, Joachim Banzhaf wrote:

> Hi list,
>
> my problem is, rpcbind gave a tcp port to nlockmgr where I assumed
> this port is reserved.

That isn't how it works. rpcbind doesn't give ports to anyone.

lockd chooses a port, and asks rpcbind to register it against the
nlockmgr service.
If lockd is choosing a port that you don't want it to, you need to
get lockd to change its behavior.

One way is to explicitly tell lockd what port to use.  The "--nlm-port"
option to rpc.statd can do this.

By default, a number will be chosen from the range given in
  /proc/sys/net/ipv4/ip_local_port_range=20

You can change that range, and that will affect all sockets which don't
ask for an explicit port.

NeilBrown


>
> Now, I didn't find the spec that says which ports rpcbind is allowed
> to use, but I thought it is the ephemeral ports, on linux defined with
> the range in kernel configuration net.ipv4.ip_local_reserved_ports
> minus exclusions from net.ipv4.ip_local_reserved_ports.
>
> So, my questions are
> 1) Is my assumption about allowed ports correct?
> 2) If not: how can I define that range?
> 3) If yes: was there a fix for that since my rather old SLES 12
> version rpcbind-0.2.1_rc4 (kernel 3.12.55)? I didn't find something
> obvious to me in the changelog.
>
> Bonus question: would it have been safe/possible to free up the port,
> e.g. with rpcbind -d? I only found out about that option after a
> reboot...
>
> BR,
> Joachim
>
> (please keep me in cc)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhAvO4ACgkQOeye3VZi
gblEng//Wsck0ksUg38yTXqaX4GPrd8YLN0akdn33oazlv1PJDQpV/rGc9RFXU1u
hJS0ZluAjmAitUi7IHifH1KFjZvm6LHtthaBrT2DNB5AwHbzlmrntZmjP+l4cd0s
n4JuWGRJOVk3JuSKcATR+sLylZ99zPZ5CKT9wgNiJI6UjIwauutsdnAidsJBfFvx
XBs8mE6A++gOLVc83a5hs7QwB95O6F0y36gVWW1snChd1AuouDseZlwtytgvWqPS
irjw/hqASAyy3jhk75pXBUP7P3GLEnCs1k/lmXMM/CGevubueEW98mXhUf6OBKYN
ouXg5acpQIRacTgEnB5tVFuyhwrxky3gB9Isi0APbGHswn9ktey0arG54dfTCE3D
o1SeGTBhLvtIbkV2UiFIaqvsuUu5mW4IewlbzPvA3k+xIv52/GtivMUvRKrzGse1
sCvz1OX5EERFbYW+E4HKYoemmxcn/PkxSlCG6e8LP3MqAdaJ4NWaH1iwbhyoXZRc
od0XwWPkLsc01KRVBxaD8ONTc/jhtVBMNF8RGjiQUO1QgRFtjuz9yZVM/T6NURh1
TaXtCrGp4yoiyjIiaBrdVN4JAEuVdzjCzoduazTTQD6763e2PboSKa9I/KNai52e
PTXqeQlMROeO5Ew2PM3dD4ig01vz4243xJ7ple6PVxH9N9tkro0=
=o48R
-----END PGP SIGNATURE-----
--=-=-=--
