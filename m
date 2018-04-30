Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60287 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbeD3C1p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 29 Apr 2018 22:27:45 -0400
From: NeilBrown <neilb@suse.com>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Date: Mon, 30 Apr 2018 12:27:34 +1000
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        rostedt <rostedt@goodmis.org>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFS: Avoid quadratic search when freeing delegations.
In-Reply-To: <633967151.5813.1524838464457.JavaMail.zimbra@efficios.com>
References: <87h8nxkyjk.fsf@notabene.neil.brown.name> <633967151.5813.1524838464457.JavaMail.zimbra@efficios.com>
Message-ID: <87d0yhig2x.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 27 2018, Mathieu Desnoyers wrote:

> ----- On Apr 27, 2018, at 1:29 AM, NeilBrown neilb@suse.com wrote:
>
>> If an NFS client has 10,000 delegations which are between 90 and 180 sec=
onds
>> old,
>> and 10,000 which are between 180 and 270 seconds old, with none of them =
still
>> in use, it is likely that the old ones are at the end of the list.
>> The first 10,000 will not be marked to be returned, the last 10,000 will.
>>=20
>> To return these, the code starts at the front of the list and finds the
>> first delegation needing to be returned (testing 10,000 on the way).
>> Then it drops rcu_readlock(), returns the delegation and starts again,
>> and does this 10,000 times.
>>=20
>> As delegation return is async, it may never block, so these 10,000
>> delegation will be returned without stopping for a breath.  The soft-lock
>> detector will notice and complain.
>>=20
>> This patch makes 3 changes.
>>=20
>> 1/ cond_resched() is added so that the soft-lockup detector doesn't noti=
ce.
>> 2/ A place-holder (an inode) is kept when locks are dropped, so that
>>   the place can usually be found again after taking rcu_readlock().
>>   This means we don't need to skip over 10,000 entries 10,000 times,
>>   100 million pointless operations - which could eaisly be a larger
>>   number.
>> 3/ If nfs_sb_active() fails, break out of the loop - there is no point
>>   in continuing.
>>=20
>> The patch also add list_for_each_entry_from_rcu() to rculist.h in
>> order to achieve 2/.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> Hi,
>> I'm hoping one of the RCU reviewers will provide an Acked-by for the
>> rculist.h change.
>>=20
>> If you'ld like 3 patches instead of just one, please let me know.  But
>> they all see to fit well together.

Thanks for your review!

>
> I think the RCU list API changes should sit in their own patch.

I guess I can split it into a separate patch if you like.  Hopefully it
can still go in through the NFS tree so we need to sync separate trees.


>
>>=20
>> thanks,
>> NeilBrown
>>=20
>>=20
>> fs/nfs/delegation.c     | 57 +++++++++++++++++++++++++++++++++++++++++++=
+-----
>> include/linux/rculist.h | 10 +++++++++
>> 2 files changed, 62 insertions(+), 5 deletions(-)
>>=20
>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>> index 1819d0d0ba4b..c3d9e21ab440 100644
>> --- a/fs/nfs/delegation.c
>> +++ b/fs/nfs/delegation.c
>> @@ -483,19 +483,56 @@ static bool nfs_delegation_need_return(struct
>> nfs_delegation *delegation)
>> int nfs_client_return_marked_delegations(struct nfs_client *clp)
>> {
>> 	struct nfs_delegation *delegation;
>> +	struct nfs_delegation *prev;
>> 	struct nfs_server *server;
>> 	struct inode *inode;
>> +	struct inode *place_holder =3D NULL;
>> 	int err =3D 0;
>>=20
>> restart:
>> +	/*
>> +	 * To avoid quadratic looping we hold an reference
>
> an reference -> a reference

Fixed, thanks.

>
>> +	 * to an inode place_holder.  Each time we restart, we
>> +	 * list nfs_servers from the server of that inode, and
>> +	 * delegation in the server from the delegations of that
>> +	 * inode.
>> +	 * prev is an RCU-protected pointer to a delegation which
>> +	 * wasn't marked for return and might be a good choice for
>> +	 * the next place_holder.
>> +	 */
>> 	rcu_read_lock();
>> -	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> -		list_for_each_entry_rcu(delegation, &server->delegations,
>> -								super_list) {
>> -			if (!nfs_delegation_need_return(delegation))
>> +	prev =3D NULL;
>> +	if (place_holder)
>> +		server =3D NFS_SERVER(place_holder);
>> +	else
>> +		server =3D list_entry_rcu(clp->cl_superblocks.next,
>> +					struct nfs_server, client_link);
>> +	list_for_each_entry_from_rcu(server, &clp->cl_superblocks, client_link=
) {
>
> Unless I'm missing something, you should define the delegation variable w=
ithin
> this scope.

I could, yes.  But that was true before the patch as well.  I don't
really want to change things that I don't need to change.
This is really a style issue.  If Trond or Anna prefer the variable in
the most local scope, I'll move it.

>
>> +		delegation =3D NULL;
>> +		if (place_holder && server =3D=3D NFS_SERVER(place_holder))
>> +			delegation =3D rcu_dereference(NFS_I(place_holder)->delegation);
>> +		if (!delegation)
>> +			delegation =3D list_entry_rcu(server->delegations.next,
>> +						    struct nfs_delegation, super_list);
>
> AFAIU, what makes this work is that you expect grabbing the inode
> reference will ensure the entry is not removed from the RCU list until
> the iput().
>

There are two lists, a per "struct nfs_client" list of "struct
nfs_server", and a per "struct nfs_server" list of "struct
nfs_delegation".

I expect that grabbing the inode will stop the filesystem from being
unmounted, so that nfs_server will remain in the list from the
nfs_client.

Also I expect that grabbing the inode will mean that it remains safe to
dereference NFS_I(place_holder)->delegation.  If that is not NULL,
then it is either the same delegation that we had before or, just
possibly, a new one.  If it is a new one it will have been added to the
end of the list, so we could end up missing a few delegations.
This is not a critical problem as this is a periodic cleanup and if it
missing some occasionally, it isn't a big problem.
However it would be easy enough to keep track of what the previous
delegation was, and only use the new one if it is the same.  I'll do
that.


>
>> +		list_for_each_entry_from_rcu(delegation, &server->delegations, super_=
list) {
>> +			struct inode *to_put =3D NULL;
>> +
>> +			if (!nfs_delegation_need_return(delegation)) {
>> +				prev =3D delegation;
>> 				continue;
>> +			}
>> 			if (!nfs_sb_active(server->super))
>> -				continue;
>> +				break;
>> +
>> +			if (prev) {
>> +				struct inode *tmp;
>
> missing whiteline, or the assignment can be done on the variable definiti=
on.
>
>> +				tmp =3D nfs_delegation_grab_inode(prev);
>> +				if (tmp) {
>> +					to_put =3D place_holder;
>> +					place_holder =3D tmp;
>> +				}
>> +			}
>> +
>> 			inode =3D nfs_delegation_grab_inode(delegation);
>> 			if (inode =3D=3D NULL) {
>> 				rcu_read_unlock();
>> @@ -505,16 +542,26 @@ int nfs_client_return_marked_delegations(struct nf=
s_client
>> *clp)
>> 			delegation =3D nfs_start_delegation_return_locked(NFS_I(inode));
>> 			rcu_read_unlock();
>>=20
>> +			if (to_put) {
>> +				iput(to_put);
>> +				to_put =3D NULL;
>
> considering the scope of to_put, I think assigning it to NULL is redundant
> with the variable definition.

True ... and that actually highlights a bug for me.  Earlier where I
have "goto restart" I need to iput(to_put).  Thanks.

>
>> +			}
>> +
>> 			err =3D nfs_end_delegation_return(inode, delegation, 0);
>> 			iput(inode);
>> 			nfs_sb_deactive(server->super);
>> +			cond_resched();
>> 			if (!err)
>> 				goto restart;
>> 			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
>> +			if (place_holder)
>> +				iput(place_holder);
>> 			return err;
>> 		}
>> 	}
>> 	rcu_read_unlock();
>> +	if (place_holder)
>> +		iput(place_holder);
>> 	return 0;
>> }
>>=20
>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>> index 127f534fec94..2d86f9869842 100644
>> --- a/include/linux/rculist.h
>> +++ b/include/linux/rculist.h
>> @@ -403,6 +403,16 @@ static inline void list_splice_tail_init_rcu(struct
>> list_head *list,
>> 	     &pos->member !=3D (head);	\
>> 	     pos =3D list_entry_rcu(pos->member.next, typeof(*pos), member))
>>=20
>> +/**
>> + * list_for_each_entry_from_rcu - iterate over a list continuing from c=
urrent
>> point
>
> There is some documentation missing about the requirements for continuing
> a RCU list iteration.

If that is true, then the already existing
list_for_each_entry_continue_rcu() also is missing some documentation.

I've removed the word "continue" so it now reads.

 * list_for_each_entry_from_rcu - iterate over a list from current point

Does it really need to be said that you actually have to have a "current
point" that is known to be in the list?  I've added

 * Iterate over the tail of a list starting from a given position,
 * which must have been in the list when the RCU read lock was taken.

in case it does help.

>
> The simple case is that both original iteration and continued iteration
> need to be in the same RCU read-side critical section.
>
> A more complex case like yours is along those lines:
>
> rcu_read_lock()
> list_iteration
>    break;
> grab inode ref (prohibit removal of node from list)
> rcu_read_unlock()
>
> rcu_read_lock()
> put inode ref
> continue list iteration
> rcu_read_unlock()
>
> I'm thinking these allowed patterns should be documented somehow,
> else we'll see list iteration being continued across different
> RCU read-side critical sections without any reference counting
> (or locking) to ensure protection against removal.

If that was a real risk, surely we would already see it with
list_for_each_entry_continue_rcu().

Thanks a lot,
NeilBrown


>
> Thanks,
>
> Mathieu
>
>> + * @pos:	the type * to use as a loop cursor.
>> + * @head:	the head for your list.
>> + * @member:	the name of the list_node within the struct.
>> + */
>> +#define list_for_each_entry_from_rcu(pos, head, member)			\
>> +	for (; &(pos)->member !=3D (head);					\
>> +		pos =3D list_entry_rcu(pos->member.next, typeof(*(pos)), member))
>> +
>> /**
>>  * hlist_del_rcu - deletes entry from hash list without re-initialization
>>  * @n: the element to delete from the hash list.
>> --
>> 2.14.0.rc0.dirty
>
> --=20
> Mathieu Desnoyers
> EfficiOS Inc.
> http://www.efficios.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlrmfxcACgkQOeye3VZi
gblRPQ/+NzZLlOcqvvJhXRT90Ukj8dCrqgsZfYMsF7ZhwL+ddWmW9/ItLVNWLJbp
/yVgpeW6qZ8KNHxTooi1d2JLBfL8Zz/bhJTN6+SW/jAs/Qf/tVcHtPfd1JDd2ox4
nSexzv7/hZF+MzpGsianUW0gSBARbyQkhSWQhuGZLU2jUbRHxkQzRFv6dxeBMbHQ
KzY97mk4q4pnTdiqGIeiCICLQmMegzm10a5mXa0k0g4rNPJr2i8cFFOWMdCv2/m3
iyNfZpl8Qpf/144KlPo7juvJaayQ7IUCvld97FSZ0pSjmduhRbCIerlzsl6OSKfJ
AVybB3NzkkJWDgp6d2TgiI0vJrvwar9wGiU/Ak3G47DBx7H5FFXJHSICoJ2zNhXz
ixC9AmhfwsBnLkGYcwgBDehookr3lxjAWzsE/hoOloUUGle+6a0Awxk5uFO8qxvz
vFvg3/BmkvdrXRiZxdBhXfdjx6AEr3OSSmXQxatGx8yo24oeNjvNm+Jk6/Mx6qiX
rlAvSp6zOszii8YLhVPWDoVXKyVHk7D/Ox+9Jtu3ht01sRBoBZgBR6BPqNSou5eM
ZScSD0hEJD/79YmCggWMHaohEK3OybP3Ray96/TpDpkL7d3ZZE0w3xRuRYvCH6M+
LRdiPBr9B/Frz8oWTlUWZLG92bXOoFaFZP/iVzbfaVb65hhuDGc=
=R1d4
-----END PGP SIGNATURE-----
--=-=-=--
