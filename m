Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44580 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753229AbdCTX0h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 19:26:37 -0400
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 21 Mar 2017 10:26:27 +1100
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH resend] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID
In-Reply-To: <CAN-5tyFPVQo26XZ=g0uRuhkJ+x95S8frSyos6J_56HP4U3Ygrg@mail.gmail.com>
References: <87y46monel.fsf@notabene.neil.brown.name> <87bmyx3q3u.fsf@notabene.neil.brown.name> <C37BA8D0-2EAF-41D7-9086-D8729D4BAD48@primarydata.com> <8737k2354z.fsf@notabene.neil.brown.name> <87zijsu4ko.fsf@notabene.neil.brown.name> <CAN-5tyFPVQo26XZ=g0uRuhkJ+x95S8frSyos6J_56HP4U3Ygrg@mail.gmail.com>
Message-ID: <87d1dbcyxo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Mar 20 2017, Olga Kornievskaia wrote:

> Since open_owner is no longer removed then the resources are not
> freed. They will not be freed until unmount  (or reboot recovery).

I don't follow your reasoning.
When the last uses for a state owner is dropped by
nfs4_put_state_owner() (e.g. when the last open file using it is
closed), nfs4_put_state_owner() will add the state to
server->state_owners_lru.

nfs4_gc_state_owners() is called periodically (every time any file is
opened I think) and it will call nfs4_remove_state_owner_locked()
on any state which is sufficiently old enough (hasn't been used in
'lease-time'), and will then call nfs4_free_state_owner().
These two will release all resources.

Does that explanation fit with your understanding?

Thanks,
NeilBrown


>
> There are (buggy) servers out there that might be forcing the client
> to keep creating new open_owners. So if they are no longer released,
> can't the client get into trouble here?
>
> On Sun, Dec 18, 2016 at 7:48 PM, NeilBrown <neilb@suse.com> wrote:
>>
>> When an NFS4ERR_BAD_SEQID is received the open-owner is removed from
>> the ->state_owners rbtree so that it will no longer be used.
>>
>> If any stateids attached to this open-owner are still in use, and if a
>> request using one gets an NFS4ERR_BAD_STATEID reply, this can for bad.
>>
>> The state is marked as needing recovery and the nfs4_state_manager()
>> is scheduled to clean up.  nfs4_state_manager() finds states to be
>> recovered by walking the state_owners rbtree.  As the open-owner is
>> not in the rbtree, the bad state is not found so nfs4_state_manager()
>> completes having done nothing.  The request is then retried, with a
>> predicatable result (indefinite retries).
>>
>> If the stateid is for a delegation, this open_owner will be used
>> to open files when the delegation is returned.  For that to work,
>> a new open-owner needs to be presented to the server.
>>
>> This patch changes NFS4ERR_BAD_SEQID handling to leave the open-owner
>> in the rbtree but updates the 'create_time' so it looks like a new
>> open-owner.  With this the indefinite retries no longer happen.
>>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>
>> Hi Trond,
>>  It appears this one got lost too.
>>  I've added a comment as I thought an explanation was needed, and
>>  renamed the function from "drop" to "reset".
>>
>> Thanks,
>> NeilBrown
>>
>>  fs/nfs/nfs4state.c | 29 +++++++++++++----------------
>>  1 file changed, 13 insertions(+), 16 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index cf869802ff23..1d152f4470cd 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -494,21 +494,18 @@ nfs4_alloc_state_owner(struct nfs_server *server,
>>  }
>>
>>  static void
>> -nfs4_drop_state_owner(struct nfs4_state_owner *sp)
>> -{
>> -       struct rb_node *rb_node = &sp->so_server_node;
>> -
>> -       if (!RB_EMPTY_NODE(rb_node)) {
>> -               struct nfs_server *server = sp->so_server;
>> -               struct nfs_client *clp = server->nfs_client;
>> -
>> -               spin_lock(&clp->cl_lock);
>> -               if (!RB_EMPTY_NODE(rb_node)) {
>> -                       rb_erase(rb_node, &server->state_owners);
>> -                       RB_CLEAR_NODE(rb_node);
>> -               }
>> -               spin_unlock(&clp->cl_lock);
>> -       }
>> +nfs4_reset_state_owner(struct nfs4_state_owner *sp)
>> +{
>> +       /* This state_owner is no longer usable, but must
>> +        * remain in place so that state recovery can find it
>> +        * and the opens associated with it.
>> +        * It may also be used for new 'open' request to
>> +        * return a delegation to the server.
>> +        * So update the 'create_time' so that it looks like
>> +        * a new state_owner.  This will cause the server to
>> +        * request an OPEN_CONFIRM to start a new sequence.
>> +        */
>> +       sp->so_seqid.create_time = ktime_get();
>>  }
>>
>>  static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
>> @@ -1113,7 +1110,7 @@ void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid)
>>
>>         sp = container_of(seqid->sequence, struct nfs4_state_owner, so_seqid);
>>         if (status == -NFS4ERR_BAD_SEQID)
>> -               nfs4_drop_state_owner(sp);
>> +               nfs4_reset_state_owner(sp);
>>         if (!nfs4_has_session(sp->so_server->nfs_client))
>>                 nfs_increment_seqid(status, seqid);
>>  }
>> --
>> 2.11.0
>>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljQZSMACgkQOeye3VZi
gbk43Q//QwCAxJI9aLoi/2m9behOd7Hb9HX8jybJVFtUSfK+SqZJT6WvbDqVclDW
DeY1DeXykPQnqvD8M84mkzg5bT6+33sXQ6JKCqwD2TFQIM3tnJkci9FKZ/qbShJ+
Kcaz2zX0mciqcbfwY/41j/xiWg2ascA2udO6V4u6oJKLvri7XjEJl5vZnc+6TEZw
5iuMqLJWpWlKfHaSaAK5OXJ6/s1gfza64r6HqpY74JZQD/0AjgMTwFoAmVgQdr/8
B77YKVzEJITGT3QX185Hk2fgzPzAnK6FzZB3Qkdx3vSlmWkyQES2AZT8rHDQZzGt
RfdK3h3DpDEzL8jgaMOq54yCx5UWhZKZ8vPHsda/bVvONxdVv9ahnO8I5DXK0dqD
Z0KzdMM9taheaQ12hOZAcCa6A0ULX73lr/JNaxf55QqfyvPTXhi+S+HWT1bRnU18
6XeH7W5G/2YIhaN3R9h89icoOcm5hDXQ9DeIxFNJNAa19qnG34LDr3P9LRkvsiPb
wllF/eV+HxDydK7Xnk60bLbP/6npj3Q/pTYirJfCQ+0qmMhYAr9Mo3Gsb7eLbDQQ
abAlxU2f7gtKjPguIjR86viRep2eAhUt1gGQ0Sg3/SMgF+USHU9uDTPW9YeTAN5k
cobdguGWF7hGyhry98Tm+iGlNOC+5QL7KNnKIcA6v3fI/i5EKik=
=xb9b
-----END PGP SIGNATURE-----
--=-=-=--
