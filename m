Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43545 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751079AbeEAVfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 May 2018 17:35:11 -0400
From: NeilBrown <neilb@suse.com>
To: paulmck@linux.vnet.ibm.com
Date: Wed, 02 May 2018 07:34:56 +1000
Cc: Steven Rostedt <rostedt@goodmis.org>,
        Josh Triplett <josh@joshtriplett.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4 v2] rculist: add list_for_each_entry_from_rcu()
In-Reply-To: <20180501141404.GD26088@linux.vnet.ibm.com>
References: <152506256513.7246.13171564155614823841.stgit@noble> <152506269061.7246.13075216914692813995.stgit@noble> <20180430052032.GA16963@localhost> <20180430134308.GT26088@linux.vnet.ibm.com> <20180430111454.722c2aa8@gandalf.local.home> <20180430153505.GW26088@linux.vnet.ibm.com> <87y3h4gjdq.fsf@notabene.neil.brown.name> <20180501141404.GD26088@linux.vnet.ibm.com>
Message-ID: <87vac7giv3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, May 01 2018, Paul E. McKenney wrote:

> On Tue, May 01, 2018 at 01:11:29PM +1000, NeilBrown wrote:
>>=20
>> list_for_each_entry_from_rcu() is an RCU version of
>> list_for_each_entry_from().  It walks a linked list under rcu
>> protection, from a given start point.
>>=20
>> It is similar to list_for_each_entry_continue_rcu() but starts *at*
>> the given position rather than *after* it.
>>=20
>> Naturally, the start point must be known to be in the list.
>>=20
>> Also update the documentation for list_for_each_entry_continue_rcu()
>> to match the documentation for the new list_for_each_entry_from_rcu(),
>> and add list_for_each_entry_from_rcu() and the already existing
>> hlist_for_each_entry_from_rcu() to section 7 of whatisRCU.txt.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> I am guessing that it would be more convenient for you to carry this
> with the patches using it, so:
>
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Thanks Paul,
 yes I do hope this patch will go in with the other NFS patches.
 I'll wait to see what Trond and Anna think before proceeding with
 anything myself.

Thanks a lot,
NeilBrown


>
> If not, please let me know.
>
> 							Thanx, Paul
>
>> ---
>>  Documentation/RCU/whatisRCU.txt |  2 ++
>>  include/linux/rculist.h         | 32 +++++++++++++++++++++++++++++++-
>>  2 files changed, 33 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisR=
CU.txt
>> index a27fbfb0efb8..b7d38bd212d2 100644
>> --- a/Documentation/RCU/whatisRCU.txt
>> +++ b/Documentation/RCU/whatisRCU.txt
>> @@ -814,11 +814,13 @@ RCU list traversal:
>>  	list_next_rcu
>>  	list_for_each_entry_rcu
>>  	list_for_each_entry_continue_rcu
>> +	list_for_each_entry_from_rcu
>>  	hlist_first_rcu
>>  	hlist_next_rcu
>>  	hlist_pprev_rcu
>>  	hlist_for_each_entry_rcu
>>  	hlist_for_each_entry_rcu_bh
>> +	hlist_for_each_entry_from_rcu
>>  	hlist_for_each_entry_continue_rcu
>>  	hlist_for_each_entry_continue_rcu_bh
>>  	hlist_nulls_first_rcu
>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>> index 127f534fec94..4786c2235b98 100644
>> --- a/include/linux/rculist.h
>> +++ b/include/linux/rculist.h
>> @@ -396,13 +396,43 @@ static inline void list_splice_tail_init_rcu(struc=
t list_head *list,
>>   * @member:	the name of the list_head within the struct.
>>   *
>>   * Continue to iterate over list of given type, continuing after
>> - * the current position.
>> + * the current position which must have been in the list when the RCU r=
ead
>> + * lock was taken.
>> + * This would typically require either that you obtained the node from a
>> + * previous walk of the list in the same RCU read-side critical section=
, or
>> + * that you held some sort of non-RCU reference (such as a reference co=
unt)
>> + * to keep the node alive *and* in the list.
>> + *
>> + * This iterator is similar to list_for_each_entry_from_rcu() except
>> + * this starts after the given position and that one starts at the given
>> + * position.
>>   */
>>  #define list_for_each_entry_continue_rcu(pos, head, member) 		\
>>  	for (pos =3D list_entry_rcu(pos->member.next, typeof(*pos), member); \
>>  	     &pos->member !=3D (head);	\
>>  	     pos =3D list_entry_rcu(pos->member.next, typeof(*pos), member))
>>=20=20
>> +/**
>> + * list_for_each_entry_from_rcu - iterate over a list from current point
>> + * @pos:	the type * to use as a loop cursor.
>> + * @head:	the head for your list.
>> + * @member:	the name of the list_node within the struct.
>> + *
>> + * Iterate over the tail of a list starting from a given position,
>> + * which must have been in the list when the RCU read lock was taken.
>> + * This would typically require either that you obtained the node from a
>> + * previous walk of the list in the same RCU read-side critical section=
, or
>> + * that you held some sort of non-RCU reference (such as a reference co=
unt)
>> + * to keep the node alive *and* in the list.
>> + *
>> + * This iterator is similar to list_for_each_entry_continue_rcu() except
>> + * this starts from the given position and that one starts from the pos=
ition
>> + * after the given position.
>> + */
>> +#define list_for_each_entry_from_rcu(pos, head, member)			\
>> +	for (; &(pos)->member !=3D (head);					\
>> +		pos =3D list_entry_rcu(pos->member.next, typeof(*(pos)), member))
>> +
>>  /**
>>   * hlist_del_rcu - deletes entry from hash list without re-initializati=
on
>>   * @n: the element to delete from the hash list.
>> --=20
>> 2.14.0.rc0.dirty
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlro3YAACgkQOeye3VZi
gbn1cg/7B/lreIqWbpbNaUQLBofW0qaNYU+036XvxxEOioH0KIjJUlEGPlTQXAMf
6+CQzRZxDv40yY9Qhplmt+7NzKlwtmE0CKX91vA7eVBPsvEj4yMb+WtUFC3g84hP
eqZW7E6KLMIT4WutuuuBnB0C6MIGvaNyRGZkZEEBdJKvCgsOjUEIuo7rrI0Vk5pR
YALDOvoUgacG1zO43UFKLXTJOcRDX+2Rkaa8zxEGZbkdCA2CayqqYAhKbaDKNv+S
WZM6C5+c/NKWqwug0g8u/7pu0RuAK1j87NSRQUwwvFYbK9LybNgI2dUjTBLbN8Zu
xdI3yEnNIvxLi4Al2LgxwgcIuNgjabl60DYDaArIfTKDsW2mQphQU7X7A89JpnAP
pesmeaaM4BeHrP6WMl3Ntl9jhYc+qupS3vgJLdiiMPHTbtqVw8Af+I9g+ieQMft2
j5936wSi6ES75qLAUrkWCEHSAZlPf4Uxaf8j1fjP9CdKvLGPanNz/VCAtb2ibvuf
luprWq3JM2dT24hvZHhUSs4SvYizs3RFBdpbBH8fF5GoEC6Jg0d7i9ByVuaRKATi
ZWMxRhsPw4hNs7DuQA4EnG91XskC9yk/b+Ri/Ma/GXTJVENDne+6Px4OqS4gsiDB
lThL/T6+1xFKPgcPmWzX0szTt0iu0nrZ9Fwe70k0+c9OhWZx2u0=
=UHW1
-----END PGP SIGNATURE-----
--=-=-=--
