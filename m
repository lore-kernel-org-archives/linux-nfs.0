From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.X File locking on NFS stil broken
Date: Wed, 09 Jun 2004 16:41:12 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1086813672.4078.24.camel@lade.trondhjem.org>
References: <20040609191758.GA29969@puettmann.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265967AbUFIUlu@vger.kernel.org>
To: Ruben Puettmann <ruben@puettmann.net>
In-Reply-To: <20040609191758.GA29969@puettmann.net>
List-ID: <nfs.lists.sourceforge.net>

P=E5 on , 09/06/2004 klokka 15:17, skreiv Ruben Puettmann:
>                 hello,
>=20
>=20
> I have a big iproblem with the nfs file locking on some 2.6 er kernel=
=20
>=20
> Kernel Server: 2.4.9
> Kernel Client: 2.6.7-rc3-bk2
>                2.6.6-rc3-mm2
>                2.6.5
<snip>
> This little testscript I  used ( got it from a friend):

That script works fine for me: I haven't seen any hangs on locking in
any of the 2.6 series kernels so far.

What does 'rpcinfo -p' show on the client and server?

Cheers,
  Trond
