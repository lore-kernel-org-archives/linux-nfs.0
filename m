From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: BUG: cannot acquire lock twice with NFSv4
Date: Sun, 11 Apr 2010 11:24:53 -0400
Message-ID: <1270999493.4663.1.camel@localhost.localdomain>
References: <wwer5mo3hf9.fsf@powwow.iut-bm.univ-fcomte.fr>
	 <wwed3y73da5.fsf@powwow.iut-bm.univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Arnaud Giersch <arnaud.giersch-T9cNH8bv7N6Vy8wrSkPSsihWMY4UYrEW@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37428 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab0DKPY7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Apr 2010 11:24:59 -0400
In-Reply-To: <wwed3y73da5.fsf-RvotKtm/pmVc2QSU14wbDhqUABtTHcxU/fObgANad5s@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2010-04-10 at 10:46 +0200, Arnaud Giersch wrote:=20
> Vendredi 09 avril 2010, vers 15:05:14 (+0200), j'ai =C3=A9crit :
>=20
> >   1. opens a first file, and acquires read lock on it ;
> >   2. opens a second file, and acquires read lock on it ;
> >   3. releases locks, and closes files.
> >
> > Both opened files are of course on the NFS mount.  On the first run=
, all
> > seems to be fine.  On the second (and subsequent) runs, the lock is
> > refused at step 2 with errno=3D37 (ENOLCK, No locks available).
>=20
> I noticed that things appear to work as expected if commit
> 8e469ebd6dc32cbaf620e134d79f740bf0ebab79 (NFSv4: Don't allow posix
> locking against servers that don't support it) is reverted.
>=20
> From what I can see, the client is granted a read delegation for the
> second file.  On the second run, the client fetches some cached state
> for this file.
>=20
> On this second run, state->flags (as in _nfs4_do_open, or in
> nfs4_proc_lock) only contains NFS_DELEGATED_STATE, while on the first
> run, it also contained NFS_O_RDONLY_STATE and NFS_STATE_POSIX_LOCKS.

Ah. Nice catch! That does indeed need to be fixed... I'll draft up a
patch tomorrow, and send you a copy.

Cheers
  Trond

