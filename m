Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AD344B2033
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:40:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457257; cv=none; b=iMxLDEcy7yUgv0WqGhsaoyMYowXaH0P5GhIfe3hyI6Rl8eM7+eZkoQC5PgqOphzE6vBv3oLo39KJOnYMlippf1e4njNYleFjk3r+Y0VrCEx//qB4LoWuWH1AB8AIsMVeE2NogcqVkrxNw+FTHnk+FsnN0w4WOxIiEbHmIu85s8o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457257; c=relaxed/simple;
	bh=x3QnMNdDkLdf1eSz6qBq8fVIDMClnQcnh2qFapDa7U8=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=MUUsX3TYRUgDAce5fwuSPXoxCmLRU8CyX3nBPA9TKYY9R5M8FxWIq9z8eJiYgJu1UK2v6ja9F2r+HDwW7mM9pOYG9ceBEfLZEByQVmiuDCWeUu4OVOujgetD7eekSHEUGZBouilUkjtnKvIwuUTlU5RgCT2e1DY+WRqwxe11lCo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bJUgrIsv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bJUgrIsv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B7D0C1F00ADF;
	Thu,  3 Sep 2026 17:40:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788457253;
	bh=bAM5Ukyublb3Y+rpQizYufNgfyY2HsMmJn1jmnfHyzo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=bJUgrIsvRqC+oDwKRa8DYnqWGpHDlA3SkxlDqEPlwmvTj0M3sxsHXvjoMfb+UW7IZ
	 5/BHhOiDmgJFJjtyiV7aTXc/pUnTIPS+HPY9zdINssgT30uYkNqJ8nlPXxdMk1Xxw0
	 GCYIQIiQATMnoV6geQEC3bm3B2sAMrgNMdqX4aEidiVfDLz+ryUQmuvRGvNqnd3dey
	 eZN5870lO8f+YCHvYRjcBgbxF0YlI3KSkWbdBLA2XGhrg7puaP8wji2N/2q/wJJgMi
	 dGd5Lji6EjGSbRFst8F64nNZ1TN8HZLl2ud50heKcz5uiJ6KE4DtoyXkRV57aMmdXo
	 qvOV59CoGKB7g==
Message-ID: <9eddd3a54291c010e259b3181d525229aa7d9690.camel@kernel.org>
Subject: Re: [PATCH v3 1/2] nfsd: add a Netlink dump of NFSv4 clients
From: Jeff Layton <jlayton@kernel.org>
To: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Date: Thu, 03 Sep 2026 13:40:50 -0400
In-Reply-To: <20260903053141.1241-2-prabhakar.pujeri@dell.com>
References: <20260903053141.1241-1-prabhakar.pujeri@dell.com>
	 <20260903053141.1241-2-prabhakar.pujeri@dell.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-09-03 at 05:31 +0000, Prabhakar Pujeri wrote:
> Administrators currently have to walk one nfsd filesystem directory per
> client to correlate basic NFSv4 identity, lease, and callback
> information. That interface is useful for detailed inspection, but it
> is awkward for monitoring tools and provides no atomic way to enumerate
> the client set.
>=20
> Add a privileged client-get dump to the nfsd Generic Netlink family.
> Emit one bounded message per confirmed or unconfirmed client with its
> server-generated client ID, peer address, minor version, client and
> callback states, signed lease time remaining, and RECLAIM_COMPLETE
> status.
>=20
> Represent the peer as separate IPv4 or IPv6 address, port, and optional
> scope-ID attributes instead of exposing a raw sockaddr structure.
>=20
> Pin each client while taking a snapshot, protect mutable lease and
> confirmation fields with the per-net client lock, and serialize against
> server shutdown with nfsd_mutex. Track client-table changes with a
> nonzero generation counter and use genl_dump_check_consistent() so a
> dump that can skip or repeat a client is marked NLM_F_DUMP_INTR. Leave
> the existing nfsd filesystem interface unchanged.
>=20
> Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
> ---
> Changes since v2 (feedback from Jeff Layton):
>=20
>   - rename the client lookup helper to nfsd_nl_find_client()
>   - validate the client-table argument explicitly instead of aliasing
>     NFSD4_NL_CLIENT_DONE to "unconfirmed"
>   - rename nfsd4_nl_client_put_address() to
>     nfsd4_nl_client_marshal_address()
>   - document the confirmed-then-unconfirmed table ordering in the dump
>     loop comments
>=20
> Changes since v1:
>=20
>   - split raw sockaddr data into address, port, and scope-ID attributes
>   - detect client-table churn with a generation counter and
>     NLM_F_DUMP_INTR
>=20
> v1: https://lore.kernel.org/r/6b42a390ce3ea9a5930e2704137fd435c6f7d27e.17=
87638668.git.prabhakar.pujeri@dell.com
> v2: https://lore.kernel.org/r/2d682b47dca234b5c270b0b1ea03022c28bbeaa3.17=
87988917.git.prabhakar.pujeri@dell.com
>=20
>  .../admin-guide/nfs/nfsd-admin-interfaces.rst |  16 ++
>  Documentation/netlink/specs/nfsd.yaml         |  93 +++++++
>  fs/nfsd/netlink.c                             |   5 +
>  fs/nfsd/netlink.h                             |   1 +
>  fs/nfsd/netns.h                               |   1 +
>  fs/nfsd/nfs4ctl.h                             |  10 +
>  fs/nfsd/nfs4state.c                           | 260 ++++++++++++++++++
>  fs/nfsd/nfsctl.c                              |  13 +
>  include/uapi/linux/nfsd_netlink.h             |  38 +++
>  9 files changed, 437 insertions(+)
>=20
> diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Do=
cumentation/admin-guide/nfs/nfsd-admin-interfaces.rst
> index c05926f7905..de2a5402587 100644
> --- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
> +++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
> @@ -29,6 +29,22 @@ Between startup and shutdown, the number of threads ma=
y be adjusted up
>  or down by additional writes to nfsd/threads or by writes to
>  nfsd/pool_threads.
> =20
> +NFSv4 client visibility
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +The privileged ``client-get`` dump in the ``nfsd`` Generic Netlink famil=
y
> +emits one message for each NFSv4 client.  Each message identifies the cl=
ient
> +by its server-generated client ID and transport address, then reports it=
s
> +minor version, client and callback states, signed lease time remaining, =
and
> +whether an NFSv4.1 or later client sent RECLAIM_COMPLETE.
> +
> +Clients can change between messages.  If that can make the dump skip or =
repeat
> +a record, the kernel sets ``NLM_F_DUMP_INTR`` and userspace should retry=
.
> +
> +The existing ``/proc/fs/nfsd/clients/`` files remain available for inspe=
ction.
> +The ``states`` file contains individual stateids, and writing ``expire``=
 to
> +``ctl`` forcibly removes the client and all state it owns.
> +
>  For more detail about files under nfsd/ and what they control, see
>  fs/nfsd/nfsctl.c; most of them have detailed comments.
> =20
> diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlin=
k/specs/nfsd.yaml
> index 642268819c6..9207a96fe59 100644
> --- a/Documentation/netlink/specs/nfsd.yaml
> +++ b/Documentation/netlink/specs/nfsd.yaml
> @@ -42,6 +42,24 @@ definitions:
>        - none
>        - tls
>        - mtls
> +  -
> +    type: enum
> +    name: client-state
> +    doc: State of an NFSv4 client record.
> +    entries:
> +      - unconfirmed
> +      - active
> +      - courtesy
> +      - expirable
> +  -
> +    type: enum
> +    name: callback-state
> +    doc: State of an NFSv4 client's callback channel.
> +    entries:
> +      - up
> +      - unknown
> +      - down
> +      - fault
> =20
>  attribute-sets:
>    -
> @@ -415,6 +433,63 @@ attribute-sets:
>          type: nest
>          nested-attributes: server-proc-entry
>          multi-attr: true
> +  -
> +    name: client
> +    attributes:
> +      -
> +        name: clientid
> +        type: u64
> +        doc: >-
> +          Server-generated NFSv4 client ID, with the boot value in the u=
pper
> +          32 bits and the per-boot ID in the lower 32 bits.
> +      -
> +        name: pad
> +        type: pad
> +      -
> +        name: address4
> +        type: u32
> +        byte-order: big-endian
> +        display-hint: ipv4
> +        doc: IPv4 peer address recorded when the client was created.
> +      -
> +        name: address6
> +        type: binary
> +        byte-order: big-endian
> +        display-hint: ipv6
> +        checks:
> +          exact-len: 16
> +        doc: IPv6 peer address recorded when the client was created.
> +      -
> +        name: address-port
> +        type: u16
> +        byte-order: big-endian
> +        doc: Transport peer port recorded when the client was created.
> +      -
> +        name: address-scope-id
> +        type: u32
> +        doc: IPv6 scope ID recorded when the client was created, when no=
nzero.
> +      -
> +        name: minor-version
> +        type: u32
> +        doc: Negotiated NFSv4 minor version.
> +      -
> +        name: state
> +        type: u32
> +        enum: client-state
> +        doc: Confirmation and courtesy-state status of the client record=
.
> +      -
> +        name: lease-remaining
> +        type: s64
> +        doc: Signed seconds until the client's lease expires; negative m=
eans overdue.
> +      -
> +        name: reclaim-complete
> +        type: flag
> +        doc: The NFSv4.1 or later client sent RECLAIM_COMPLETE.
> +      -
> +        name: callback-state
> +        type: u32
> +        enum: callback-state
> +        doc: Health of the client's callback channel.
> =20
>  operations:
>    list:
> @@ -627,6 +702,24 @@ operations:
>              - proc4-ops
>              - proc4ops-ops
>              - proc4cb-ops
> +    -
> +      name: client-get
> +      doc: dump NFSv4 clients
> +      attribute-set: client
> +      flags: [admin-perm]
> +      dump:
> +        reply:
> +          attributes:
> +            - clientid
> +            - address4
> +            - address6
> +            - address-port
> +            - address-scope-id
> +            - minor-version
> +            - state
> +            - lease-remaining
> +            - reclaim-complete
> +            - callback-state
> =20
>  mcast-groups:
>    list:
> diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
> index eba8b353f41..48bc499136b 100644
> --- a/fs/nfsd/netlink.c
> +++ b/fs/nfsd/netlink.c
> @@ -230,6 +230,11 @@ static const struct genl_split_ops nfsd_nl_ops[] =3D=
 {
>  		.dumpit	=3D nfsd_nl_server_stats_get_dumpit,
>  		.flags	=3D GENL_CMD_CAP_DUMP,
>  	},
> +	{
> +		.cmd	=3D NFSD_CMD_CLIENT_GET,
> +		.dumpit	=3D nfsd_nl_client_get_dumpit,
> +		.flags	=3D GENL_ADMIN_PERM | GENL_CMD_CAP_DUMP,
> +	},
>  };
> =20
>  static const struct genl_multicast_group nfsd_nl_mcgrps[] =3D {
> diff --git a/fs/nfsd/netlink.h b/fs/nfsd/netlink.h
> index 027e2953db2..de7593e6408 100644
> --- a/fs/nfsd/netlink.h
> +++ b/fs/nfsd/netlink.h
> @@ -44,6 +44,7 @@ int nfsd_nl_unlock_filesystem_doit(struct sk_buff *skb,=
 struct genl_info *info);
>  int nfsd_nl_unlock_export_doit(struct sk_buff *skb, struct genl_info *in=
fo);
>  int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
>  				    struct netlink_callback *cb);
> +int nfsd_nl_client_get_dumpit(struct sk_buff *skb, struct netlink_callba=
ck *cb);
> =20
>  enum {
>  	NFSD_NLGRP_NONE,
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 0ce7da20aba..d30af86cf78 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -105,6 +105,7 @@ struct nfsd_net {
>  	struct list_head *unconf_id_hashtbl;
>  	struct rb_root unconf_name_tree;
>  	struct list_head *sessionid_hashtbl;
> +	u32 nfs4_client_generation;	/* protected by client_lock, never zero */
>  	/*
>  	 * client_lru holds client queue ordered by nfs4_client.cl_time
>  	 * for lease renewal.
> diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
> index bcec4c4ef1d..44cbb0fac58 100644
> --- a/fs/nfsd/nfs4ctl.h
> +++ b/fs/nfsd/nfs4ctl.h
> @@ -20,8 +20,10 @@
>  struct net;
>  struct inode;
>  struct dentry;
> +struct sk_buff;
>  struct svc_rqst;
>  struct nfsd_net;
> +struct netlink_callback;
> =20
>  #ifdef CONFIG_NFSD_V4
>  extern unsigned long max_delegations;
> @@ -37,6 +39,8 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
>  int nfsd4_create_laundry_wq(void);
>  void nfsd4_destroy_laundry_wq(void);
>  bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *ino=
de);
> +int nfsd4_nl_client_get_dumpit(struct sk_buff *skb,
> +			       struct netlink_callback *cb);
> =20
>  extern int nfsd4_is_junction(struct dentry *dentry);
>  extern int register_cld_notifier(void);
> @@ -68,6 +72,12 @@ static inline bool nfsd_wait_for_delegreturn(struct sv=
c_rqst *rqstp,
>  	return false;
>  }
> =20
> +static inline int nfsd4_nl_client_get_dumpit(struct sk_buff *skb,
> +					     struct netlink_callback *cb)
> +{
> +	return 0;
> +}
> +
>  static inline int nfsd4_is_junction(struct dentry *dentry)
>  {
>  	return 0;
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ae0af9490fb..f947ac20eed 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -59,6 +59,7 @@
>  #include "pnfs.h"
>  #include "filecache.h"
>  #include "nfs4xdr_gen.h"
> +#include "netlink.h"
>  #include "trace.h"
> =20
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
> @@ -2842,6 +2843,14 @@ free_client(struct nfs4_client *clp)
>  	nfsd4_put_client(clp);
>  }
> =20
> +static void nfsd4_bump_client_generation(struct nfsd_net *nn)
> +{
> +	lockdep_assert_held(&nn->client_lock);
> +
> +	if (++nn->nfs4_client_generation =3D=3D 0)
> +		nn->nfs4_client_generation++;
> +}
> +
>  /* must be called under the client_lock */
>  static void
>  unhash_client_locked(struct nfs4_client *clp)
> @@ -2856,6 +2865,7 @@ unhash_client_locked(struct nfs4_client *clp)
>  	/* Make it invisible */
>  	if (!list_empty(&clp->cl_idhash)) {
>  		list_del_init(&clp->cl_idhash);
> +		nfsd4_bump_client_generation(nn);
>  		if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
>  			rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
>  		else
> @@ -3232,6 +3242,253 @@ static const char *cb_state2str(int state)
>  	return "UNDEFINED";
>  }
> =20
> +enum nfsd4_nl_client_table {
> +	NFSD4_NL_CLIENT_CONFIRMED,
> +	NFSD4_NL_CLIENT_UNCONFIRMED,
> +	NFSD4_NL_CLIENT_DONE,
> +};
> +
> +struct nfsd4_nl_client {
> +	struct sockaddr_storage	address;
> +	u64			clientid;
> +	s64			lease_remaining;
> +	u32			minor_version;
> +	u32			state;
> +	u32			callback_state;
> +	bool			reclaim_complete;
> +};
> +
> +static u32 nfsd4_nl_client_state(bool confirmed, unsigned int state)
> +{
> +	if (!confirmed)
> +		return NFSD_CLIENT_STATE_UNCONFIRMED;
> +
> +	switch (state) {
> +	case NFSD4_COURTESY:
> +		return NFSD_CLIENT_STATE_COURTESY;
> +	case NFSD4_EXPIRABLE:
> +		return NFSD_CLIENT_STATE_EXPIRABLE;
> +	default:
> +		return NFSD_CLIENT_STATE_ACTIVE;
> +	}
> +}
> +
> +static u32 nfsd4_nl_callback_state(int state)
> +{
> +	switch (state) {
> +	case NFSD4_CB_UP:
> +		return NFSD_CALLBACK_STATE_UP;
> +	case NFSD4_CB_DOWN:
> +		return NFSD_CALLBACK_STATE_DOWN;
> +	case NFSD4_CB_FAULT:
> +		return NFSD_CALLBACK_STATE_FAULT;
> +	default:
> +		return NFSD_CALLBACK_STATE_UNKNOWN;
> +	}
> +}
> +
> +static struct nfs4_client *
> +nfsd_nl_find_client(struct nfsd_net *nn, enum nfsd4_nl_client_table tabl=
e,
> +		    unsigned long bucket, unsigned long skip,
> +		    struct netlink_callback *cb)
> +{
> +	struct nfs4_client *clp =3D NULL;
> +	struct nfs4_client *pos;
> +	struct list_head *head;
> +	unsigned long index =3D 0;
> +
> +	lockdep_assert_held(&nfsd_mutex);
> +
> +	switch (table) {
> +	case NFSD4_NL_CLIENT_CONFIRMED:
> +		head =3D &nn->conf_id_hashtbl[bucket];
> +		break;
> +	case NFSD4_NL_CLIENT_UNCONFIRMED:
> +		head =3D &nn->unconf_id_hashtbl[bucket];
> +		break;
> +	default:
> +		return NULL;
> +	}
> +
> +	spin_lock(&nn->client_lock);
> +	cb->seq =3D nn->nfs4_client_generation;
> +	list_for_each_entry(pos, head, cl_idhash) {
> +		if (index++ !=3D skip)
> +			continue;
> +		kref_get(&pos->cl_nfsdfs.cl_ref);
> +		clp =3D pos;
> +		break;
> +	}
> +	spin_unlock(&nn->client_lock);
> +	return clp;
> +}
> +
> +static void nfsd4_nl_client_snapshot(struct nfsd_net *nn,
> +				     struct nfs4_client *clp,
> +				     struct nfsd4_nl_client *client)
> +{
> +	unsigned int state;
> +	time64_t last_renew;
> +	bool confirmed;
> +
> +	spin_lock(&nn->client_lock);
> +	last_renew =3D clp->cl_time;
> +	confirmed =3D test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
> +	state =3D READ_ONCE(clp->cl_state);
> +	spin_unlock(&nn->client_lock);
> +
> +	memcpy(&client->address, &clp->cl_addr, sizeof(client->address));
> +	client->clientid =3D (u64)clp->cl_clientid.cl_boot << 32 |
> +			   clp->cl_clientid.cl_id;
> +	client->lease_remaining =3D last_renew ?
> +		last_renew + READ_ONCE(nn->nfsd4_lease) -
> +		ktime_get_boottime_seconds() : 0;
> +	client->minor_version =3D clp->cl_minorversion;
> +	client->state =3D nfsd4_nl_client_state(confirmed, state);
> +	client->callback_state =3D
> +		nfsd4_nl_callback_state(READ_ONCE(clp->cl_cb_state));
> +	client->reclaim_complete =3D
> +		test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags);
> +}
> +
> +static int
> +nfsd4_nl_client_marshal_address(struct sk_buff *skb,
> +				const struct sockaddr_storage *address)
> +{
> +	switch (address->ss_family) {
> +	case AF_INET: {
> +		const struct sockaddr_in *sin =3D
> +			(const struct sockaddr_in *)address;
> +
> +		if (nla_put_in_addr(skb, NFSD_A_CLIENT_ADDRESS4,
> +				    sin->sin_addr.s_addr) ||
> +		    nla_put_be16(skb, NFSD_A_CLIENT_ADDRESS_PORT,
> +				 sin->sin_port))
> +			return -EMSGSIZE;
> +		break;
> +	}
> +	case AF_INET6: {
> +		const struct sockaddr_in6 *sin6 =3D
> +			(const struct sockaddr_in6 *)address;
> +
> +		if (nla_put_in6_addr(skb, NFSD_A_CLIENT_ADDRESS6,
> +				     &sin6->sin6_addr) ||
> +		    nla_put_be16(skb, NFSD_A_CLIENT_ADDRESS_PORT,
> +				 sin6->sin6_port) ||
> +		    (sin6->sin6_scope_id &&
> +		     nla_put_u32(skb, NFSD_A_CLIENT_ADDRESS_SCOPE_ID,
> +				 sin6->sin6_scope_id)))
> +			return -EMSGSIZE;
> +		break;
> +	}
> +	}
> +	return 0;
> +}
> +
> +static int nfsd4_nl_client_compose_msg(struct sk_buff *skb,
> +				       struct netlink_callback *cb,
> +				       const struct nfsd4_nl_client *client)
> +{
> +	void *hdr;
> +
> +	hdr =3D genlmsg_put(skb, NETLINK_CB(cb->skb).portid,
> +			  cb->nlh->nlmsg_seq, &nfsd_nl_family, NLM_F_MULTI,
> +			  NFSD_CMD_CLIENT_GET);
> +	if (!hdr)
> +		return -EMSGSIZE;
> +	genl_dump_check_consistent(cb, hdr);
> +
> +	if (nla_put_u64_64bit(skb, NFSD_A_CLIENT_CLIENTID, client->clientid,
> +			      NFSD_A_CLIENT_PAD) ||
> +	    nfsd4_nl_client_marshal_address(skb, &client->address) ||
> +	    nla_put_u32(skb, NFSD_A_CLIENT_MINOR_VERSION,
> +			client->minor_version) ||
> +	    nla_put_u32(skb, NFSD_A_CLIENT_STATE, client->state) ||
> +	    nla_put_s64(skb, NFSD_A_CLIENT_LEASE_REMAINING,
> +			client->lease_remaining, NFSD_A_CLIENT_PAD) ||
> +	    (client->reclaim_complete &&
> +	     nla_put_flag(skb, NFSD_A_CLIENT_RECLAIM_COMPLETE)) ||
> +	    nla_put_u32(skb, NFSD_A_CLIENT_CALLBACK_STATE,
> +			client->callback_state))
> +		goto err_cancel;
> +
> +	genlmsg_end(skb, hdr);
> +	return 0;
> +
> +err_cancel:
> +	genlmsg_cancel(skb, hdr);
> +	return -EMSGSIZE;
> +}
> +
> +/**
> + * nfsd4_nl_client_get_dumpit - dump NFSv4 client information
> + * @skb: reply buffer
> + * @cb: netlink metadata and command arguments
> + *
> + * One netlink message is emitted for each client. cb->args tracks the c=
lient
> + * table, hash bucket, and offset within that bucket. Client table chang=
es can
> + * cause an object to be skipped or repeated between calls; in that case=
 the
> + * affected message or NLMSG_DONE is marked with NLM_F_DUMP_INTR.
> + *
> + * Returns the size of the reply or a negative errno.
> + */
> +int nfsd4_nl_client_get_dumpit(struct sk_buff *skb,
> +			       struct netlink_callback *cb)
> +{
> +	struct nfsd4_nl_client client;
> +	struct nfs4_client *clp;
> +	struct nfsd_net *nn;
> +	struct net *net;
> +	int ret =3D 0;
> +
> +	net =3D sock_net(skb->sk);
> +	nn =3D net_generic(net, nfsd_net_id);
> +	mutex_lock(&nfsd_mutex);
> +	if (!test_bit(NFSD_NET_UP, &nn->flags)) {
> +		ret =3D -ENODEV;
> +		goto out_unlock;
> +	}
> +
> +	/*
> +	 * Table values are ordered: confirmed clients first, then
> +	 * unconfirmed, then done. cb->args[0] tracks which table the
> +	 * dump is visiting, args[1] the hash bucket in it, and args[2]
> +	 * the client's offset within that bucket.
> +	 */
> +	while (cb->args[0] < NFSD4_NL_CLIENT_DONE) {
> +		if (cb->args[1] >=3D CLIENT_HASH_SIZE) {
> +			cb->args[0]++;

Maybe I wasn't clear in my earlier email. cb->args[0] is an enum. Why
are you incrementing through it like this? It's weird and it makes it
unclear what this code is doing.

It's also brittle. If someone expands that enum later, it could be
problematic.

Given that there are only two possible tables, there's no reason to
make this so clever. Please rework this to be more human-readable.

What I'd do is move all of the stuff inside the while() loop into a
helper function, and then just call that twice: once with
NFSD4_NL_CLIENT_CONFIRMED and once with NFSD4_NL_CLIENT_UNCONFIRMED.

> +			cb->args[1] =3D 0;
> +			cb->args[2] =3D 0;
> +			continue;
> +		}
> +
> +		clp =3D nfsd_nl_find_client(nn, cb->args[0], cb->args[1],
> +					  cb->args[2], cb);
> +		if (!clp) {
> +			cb->args[1]++;
> +			cb->args[2] =3D 0;
> +			continue;
> +		}
> +
> +		memset(&client, 0, sizeof(client));
> +		nfsd4_nl_client_snapshot(nn, clp, &client);
> +		ret =3D nfsd4_nl_client_compose_msg(skb, cb, &client);
> +		nfsd4_put_client(clp);
> +		if (ret) {
> +			if (skb->len)
> +				ret =3D skb->len;
> +			goto out_unlock;
> +		}
> +		cb->args[2]++;
> +	}
> +	ret =3D skb->len;
> +
> +out_unlock:
> +	mutex_unlock(&nfsd_mutex);
> +	return ret;
> +}
> +
>  static int client_info_show(struct seq_file *m, void *v)
>  {
>  	struct inode *inode =3D file_inode(m->file);
> @@ -4026,6 +4283,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
>  	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
>  	idhashval =3D clientid_hashval(clp->cl_clientid.cl_id);
>  	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
> +	nfsd4_bump_client_generation(nn);
>  	renew_client_locked(clp);
>  }
> =20
> @@ -4038,6 +4296,7 @@ move_to_confirmed(struct nfs4_client *clp)
>  	lockdep_assert_held(&nn->client_lock);
> =20
>  	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
> +	nfsd4_bump_client_generation(nn);
>  	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
>  	add_clp_to_name_tree(clp, &nn->conf_name_tree);
>  	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
> @@ -10160,6 +10419,7 @@ static int nfs4_state_create_net(struct net *net)
>  	INIT_LIST_HEAD(&nn->del_recall_lru);
>  	spin_lock_init(&nn->deleg_lock);
>  	spin_lock_init(&nn->client_lock);
> +	nn->nfs4_client_generation =3D 1;
>  	spin_lock_init(&nn->s2s_cp_lock);
>  	idr_init(&nn->s2s_cp_stateids);
>  	atomic_set(&nn->pending_async_copies, 0);
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index c6f6bc3b128..4d11592cdf8 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1649,6 +1649,19 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *=
skb,
>  	return ret;
>  }
> =20
> +/**
> + * nfsd_nl_client_get_dumpit - dump NFSv4 client information
> + * @skb: reply buffer
> + * @cb: netlink metadata and command arguments
> + *
> + * Returns the size of the reply or a negative errno.
> + */
> +int nfsd_nl_client_get_dumpit(struct sk_buff *skb,
> +			      struct netlink_callback *cb)
> +{
> +	return nfsd4_nl_client_get_dumpit(skb, cb);
> +}
> +
>  /**
>   * nfsd_nl_fh_key_set - helper to copy fh_key from userspace
>   * @attr: nlattr NFSD_A_SERVER_FH_KEY
> diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_=
netlink.h
> index 87da1d0bb21..715acb4104c 100644
> --- a/include/uapi/linux/nfsd_netlink.h
> +++ b/include/uapi/linux/nfsd_netlink.h
> @@ -50,6 +50,26 @@ enum nfsd_xprtsec_mode {
>  	NFSD_XPRTSEC_MODE_MTLS =3D 4,
>  };
> =20
> +/*
> + * State of an NFSv4 client record.
> + */
> +enum nfsd_client_state {
> +	NFSD_CLIENT_STATE_UNCONFIRMED,
> +	NFSD_CLIENT_STATE_ACTIVE,
> +	NFSD_CLIENT_STATE_COURTESY,
> +	NFSD_CLIENT_STATE_EXPIRABLE,
> +};
> +
> +/*
> + * State of an NFSv4 client's callback channel.
> + */
> +enum nfsd_callback_state {
> +	NFSD_CALLBACK_STATE_UP,
> +	NFSD_CALLBACK_STATE_UNKNOWN,
> +	NFSD_CALLBACK_STATE_DOWN,
> +	NFSD_CALLBACK_STATE_FAULT,
> +};
> +
>  enum {
>  	NFSD_A_CACHE_NOTIFY_CACHE_TYPE =3D 1,
> =20
> @@ -260,6 +280,23 @@ enum {
>  	NFSD_A_SERVER_STATS_MAX =3D (__NFSD_A_SERVER_STATS_MAX - 1)
>  };
> =20
> +enum {
> +	NFSD_A_CLIENT_CLIENTID =3D 1,
> +	NFSD_A_CLIENT_PAD,
> +	NFSD_A_CLIENT_ADDRESS4,
> +	NFSD_A_CLIENT_ADDRESS6,
> +	NFSD_A_CLIENT_ADDRESS_PORT,
> +	NFSD_A_CLIENT_ADDRESS_SCOPE_ID,
> +	NFSD_A_CLIENT_MINOR_VERSION,
> +	NFSD_A_CLIENT_STATE,
> +	NFSD_A_CLIENT_LEASE_REMAINING,
> +	NFSD_A_CLIENT_RECLAIM_COMPLETE,
> +	NFSD_A_CLIENT_CALLBACK_STATE,
> +
> +	__NFSD_A_CLIENT_MAX,
> +	NFSD_A_CLIENT_MAX =3D (__NFSD_A_CLIENT_MAX - 1)
> +};
> +
>  enum {
>  	NFSD_CMD_RPC_STATUS_GET =3D 1,
>  	NFSD_CMD_THREADS_SET,
> @@ -280,6 +317,7 @@ enum {
>  	NFSD_CMD_UNLOCK_FILESYSTEM,
>  	NFSD_CMD_UNLOCK_EXPORT,
>  	NFSD_CMD_SERVER_STATS_GET,
> +	NFSD_CMD_CLIENT_GET,
> =20
>  	__NFSD_CMD_MAX,
>  	NFSD_CMD_MAX =3D (__NFSD_CMD_MAX - 1)

--=20
Jeff Layton <jlayton@kernel.org>
