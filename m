Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:15214 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753235AbbHEQdR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 12:33:17 -0400
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
	<m2bnemg64d.fsf@discipline.rit.edu>
	<20150805111132.01a14348@tlielax.poochiereds.net>
Date: Wed, 05 Aug 2015 12:33:16 -0400
In-Reply-To: <20150805111132.01a14348@tlielax.poochiereds.net> (Jeff Layton's
	message of "Wed, 5 Aug 2015 11:11:32 -0400")
Message-ID: <m2pp31bsqb.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> I'm not sure I'm following your shorthand correctly, but, I'm guessing
> the above is that you're creating a stateid and then calling
> init_open_stateid on it to hash it?
>
> If you can flesh out the description of the race, it might be more
> clear.

Sorry, knew that was a bit terse.

nfsd4_process_open2                    nfsd4_close

stp = open->op_stp;
 nfs4_alloc_stid, refcount is 1

init_open_stateid(stp, fp, open);
 is hashed, refcount is 2

                                 nfs4_preprocess_seqid_op()
				 finds the same stateid,
				 refcount is 3

                                 nfsd4_close_open_stateid()
                                 unhashes stateid,
                                 put_ol_stateid_locked() drops refcount
                                 refcount is 2
nfs4_get_vfs_file() returns
with status due to:
 nfsd_open()
  nfsd_open_break_lease()
   break_lease() returning
    -EWOULDBLOCK

release_open_stateid()
 calls unhash_open_stateid()
 attempts to unhash,
 WARN generated for list_del

 proceeds to call put_ol_stateid_locked()
 decrements refcount inappropriately
 refcount is now 1.

                                 nfs4_put_stid()
				 refcount is 0, memory is freed

 nfs4_put_stid
 calls atomic_dec_and_lock()
 use after free
 first corrupt byte is 6a
 because of atomic decrement
 with slub_debug on

> Unless...the initial task that created the stateid got _really_
> stalled, and another OPEN raced in, found that stateid and was able to
> reply quickly. Then the client could send a CLOSE for that second OPEN
> before the first opener ever finished.

Sounds plausible given the environment. Would take more effort to
directly prove. I have directly observed the same stateid being used in
the above race.

> If you had multiple racing OPENs then one could find the stateid that
> was previously hashed. A simple fix might be to just use list_del_init
> calls in unhash_ol_stateid. That should make any second list_del's a
> no-op.
>
> Whether that's sufficient to fix the mem corruption, I'm not sure...

It's sc_count decrementing when the unhashing "fails" or is going to
fail. For instance, this kind of construct will prevent one of the
possible use-after-free scenarios.

static void release_open_stateid(struct nfs4_ol_stateid *stp)
{
        LIST_HEAD(reaplist);

        spin_lock(&stp->st_stid.sc_client->cl_lock);
        if (stp->st_perfile->next != LIST_POISON1) {
         unhash_open_stateid(stp, &reaplist);
         put_ol_stateid_locked(stp, &reaplist);
        }
        spin_unlock(&stp->st_stid.sc_client->cl_lock);
        free_ol_stateid_reaplist(&reaplist);
}

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
