Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:63020 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751598AbbHDUSL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 16:18:11 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
References: <m23809zl8z.fsf@discipline.rit.edu>
	<m2zj2hwk4e.fsf@discipline.rit.edu>
	<20150728090206.1331e476@tlielax.poochiereds.net>
	<m2wpxktjfc.fsf@discipline.rit.edu>
	<20150728114933.6f917374@tlielax.poochiereds.net>
	<20150728210434.GC9349@fieldses.org>
	<m24mknq9ga.fsf@discipline.rit.edu>
	<m28u9yoi6z.fsf@discipline.rit.edu>
	<m2bnetnbme.fsf@discipline.rit.edu>
	<20150730085723.0ab8e76c@tlielax.poochiereds.net>
Date: Tue, 04 Aug 2015 16:18:10 -0400
In-Reply-To: <20150730085723.0ab8e76c@tlielax.poochiereds.net> (Jeff Layton's
	message of "Thu, 30 Jul 2015 08:57:23 -0400")
Message-ID: <m2bnemg64d.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> In any case, I think this explains where the "no readable file" warning
> is coming from, but I'm not sure yet about the mem corruption...

Forgive my shorthand, but I think this is what we're seeing:

open2              close
 create 1 (idr)
 init 2 (hashed)

                   close preprocess_seqid 3 (local ref in nfsd4_close)
		   close_open_stateid 2 -> unhashed (unhashed)

 release_open_stateid 1 -> list_del corruption (because unhashed already
                        -> should still be refcount 2?)

                   nfs4_put_stid 0 -> destroyed

 nfs4_put_stid 0 -> use after free

This also explains the '6a' as the first byte, as the final
nfs4_put_stid will decrement sc_count first. There are other permutations.

Also, the return-with-status from nfs_get_vfs_file() appears to be break_lease()
(much further down) returning -EWOULDBLOCK (in both cases, memory
corruption and the simple warning case)

Thanks,

Andy
-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
