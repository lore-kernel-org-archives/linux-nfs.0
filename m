From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] lockd
Date: Mon, 04 Oct 2004 20:01:31 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1096912891.22446.67.camel@lade.trondhjem.org>
References: <41617958.2020406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268435AbUJDSEX@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41617958.2020406@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

P=E5 m=E5 , 04/10/2004 klokka 18:24, skreiv Steve Dickson:
> Hey Neil,
>=20
> Attached is a patch that fixes some potential SMP races
> in the lockd code that were identified by the SLEEP_ON_BKLCHECK
> that was (at one time) in the -mm tree...

Just for the record: the "SMP race condition" argument given here is
completely bogus. sleep_on_* is quite safe to use when the SMP races ar=
e
being handled using the BKL, as is the case here.

That said, I agree that the patch is of interest given the long term
goal of removing the BKL completely. Perhaps you could therefore also
amend your changelog entry text to reflect this motive?

Cheers,
  Trond
