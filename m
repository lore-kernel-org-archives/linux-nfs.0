From: Arnaud Giersch <arnaud.giersch-T9cNH8bv7N6Vy8wrSkPSsihWMY4UYrEW@public.gmane.org>
Subject: Re: BUG: cannot acquire lock twice with NFSv4
Date: Sat, 10 Apr 2010 10:46:58 +0200
Message-ID: <wwed3y73da5.fsf@powwow.iut-bm.univ-fcomte.fr>
References: <wwer5mo3hf9.fsf@powwow.iut-bm.univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from messager.iut-bm.univ-fcomte.fr ([194.57.86.195]:42447 "EHLO
	messager.iut-bm.univ-fcomte.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750924Ab0DJIrF convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Apr 2010 04:47:05 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by messager.iut-bm.univ-fcomte.fr (Postfix) with ESMTP id 488362B4F0
	for <linux-nfs@vger.kernel.org>; Sat, 10 Apr 2010 10:47:00 +0200 (CEST)
Received: from messager.iut-bm.univ-fcomte.fr ([127.0.0.1])
	by localhost (messager.iut-bm.univ-fcomte.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Bj05pfKoU6Ic for <linux-nfs@vger.kernel.org>;
	Sat, 10 Apr 2010 10:46:58 +0200 (CEST)
Received: from powwow.iut-bm.univ-fcomte.fr (powwow.iut-bm.univ-fcomte.fr [193.52.61.133])
	by messager.iut-bm.univ-fcomte.fr (Postfix) with ESMTPS id 49A3A2B4EA
	for <linux-nfs@vger.kernel.org>; Sat, 10 Apr 2010 10:46:58 +0200 (CEST)
Received: from giersch by powwow.iut-bm.univ-fcomte.fr with local (Exim 4.71)
	(envelope-from <arnaud.giersch-T9cNH8bv7N6Vy8wrSkPSsihWMY4UYrEW@public.gmane.org>)
	id 1O0WLC-0005Yx-AK
	for linux-nfs@vger.kernel.org; Sat, 10 Apr 2010 10:46:58 +0200
In-Reply-To: <wwer5mo3hf9.fsf-RvotKtm/pmVc2QSU14wbDhqUABtTHcxU/fObgANad5s@public.gmane.org> (Arnaud Giersch's
	message of "Fri, 09 Apr 2010 15:05:14 +0200")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Vendredi 09 avril 2010, vers 15:05:14 (+0200), j'ai =C3=A9crit=C2=A0:

>   1. opens a first file, and acquires read lock on it ;
>   2. opens a second file, and acquires read lock on it ;
>   3. releases locks, and closes files.
>
> Both opened files are of course on the NFS mount.  On the first run, =
all
> seems to be fine.  On the second (and subsequent) runs, the lock is
> refused at step 2 with errno=3D37 (ENOLCK, No locks available).

I noticed that things appear to work as expected if commit
8e469ebd6dc32cbaf620e134d79f740bf0ebab79 (NFSv4: Don't allow posix
locking against servers that don't support it) is reverted.

=46rom what I can see, the client is granted a read delegation for the
second file.  On the second run, the client fetches some cached state
for this file.

On this second run, state->flags (as in _nfs4_do_open, or in
nfs4_proc_lock) only contains NFS_DELEGATED_STATE, while on the first
run, it also contained NFS_O_RDONLY_STATE and NFS_STATE_POSIX_LOCKS.

Then, I do not fully understand the code, and I am not able to suggest
any satisfying patch to correct the problem.

Regards,

        Arnaud Giersch
