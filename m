Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D18971A2C04;
	Thu,  8 Oct 2026 18:42:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791484936; cv=none; b=KunEvs6SCjevCFI17/CB2mTYfXDfNUrge0kMpEkEvZvZjzDGXwAfzrVaEhR3mOb2PhJRGJBYFW3N/uN7c+mbfKdtBMvKh03v5zfIbZWmQ64vh1uKt+FRuDF6FUKBiU0E6ZBTSqSmyTEKeDo2GQf8iSBKU/bCr3uBXlGc30lmj8Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791484936; c=relaxed/simple;
	bh=wft4+SSpsK3wyExMnFUAdxsT4yI2WkCQqey/33gKeZs=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=rLNrH+SDSEli0hrGjYy528oXxmV85jUn4ePaVaEzsGBxkHv9f3/sTo5Q44McXXdBQpmp+oRa//dScpM0XhFHT1yda/urBsLVqoXDfqoWjlFympN2ox7TCDD4i1jGz+i7eIuExG1CyKP9EX5P61a49tiV6b1HbtNgePTvPPCdsso=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M3ITaNbR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M3ITaNbR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0F4F11F0089A;
	Thu,  8 Oct 2026 18:42:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791484934;
	bh=dt5E1acHpjDvPlqElHR2yYYQvv0YRmPVztOJq4vaS84=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=M3ITaNbR3/aV2mlaO4JNy3kzVgiHhymwcsZEQ6rfApZS4dnXXgdNrqb3Le/BMtqDr
	 Vf1TkYv1IQJQ/O3UT+Ot+djiCcEq0SLyRl2SxkasiGKiZ84AE/4jkPk4n1Gq7Etc/9
	 WZ22ZvrrPWrlD+ooNRLNdZoujPXDm2te0t+cDVT/BOq14yFj3/fTAhnT8oOclGxd6b
	 b1esNu+NVRkSqE9EpwZzu/yS4CTIlGQo0XrowdP5uOMBIeCPsqxUSxJmB43KLc19kU
	 CvRbSXllVziVqjUrlOiEMlKMOp8kU7wiRBt/zoi+fnp+8BAUJgu3yDjEZwdBVTKjPv
	 8y9Zn3P/AZ9FA==
Message-ID: <bfc94fc2c3501dc91462e99be11495bb893af731.camel@kernel.org>
Subject: Re: [PATCH RFC v2 9/9] Documentation: describe RPC server transport
 classes and the BPF classifier
From: Jeff Layton <jlayton@kernel.org>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Chuck Lever
	 <cel@kernel.org>, NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>, 
	bpf@vger.kernel.org, Martin KaFai Lau <martin.lau@linux.dev>
Date: Thu, 08 Oct 2026 20:42:11 +0200
In-Reply-To: <ef239ae64ae4379ad9a55d4fc3642d659dad4ef8.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
	 <ef239ae64ae4379ad9a55d4fc3642d659dad4ef8.1791402701.git.bcodding@hammerspace.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-10-07 at 15:59 -0400, Benjamin Coddington wrote:
> From: Benjamin Coddington <bcodding@hammerspace.com>
>=20
> Dispatch round-robin across clients changes how a service shares its
> threads, and the classes come from a BPF program the administrator
> loads, so the administrator needs the model, the class word, and the
> procedure.  Add a page with those: install a classifier with
> svc-classify (build, attach, fill the map, check, change, remove, keep
> across reboots), six class maps and the share each gives its clients,
> the tracepoint that shows the class, and how the hook, the program and
> the attach model work underneath.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  Documentation/filesystems/nfs/index.rst       |   1 +
>  .../filesystems/nfs/rpc-server-clients.rst    | 394 ++++++++++++++++++
>  2 files changed, 395 insertions(+)
>  create mode 100644 Documentation/filesystems/nfs/rpc-server-clients.rst
>=20
> diff --git a/Documentation/filesystems/nfs/index.rst b/Documentation/file=
systems/nfs/index.rst
> index a29a212b5b4d..57a61ce0533d 100644
> --- a/Documentation/filesystems/nfs/index.rst
> +++ b/Documentation/filesystems/nfs/index.rst
> @@ -16,3 +16,4 @@ NFS
>     nfsd-io-modes
>     knfsd-stats
>     reexport
> +   rpc-server-clients
> diff --git a/Documentation/filesystems/nfs/rpc-server-clients.rst b/Docum=
entation/filesystems/nfs/rpc-server-clients.rst
> new file mode 100644
> index 000000000000..b08351a88314
> --- /dev/null
> +++ b/Documentation/filesystems/nfs/rpc-server-clients.rst
> @@ -0,0 +1,394 @@
> +.. SPDX-License-Identifier: GPL-2.0
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +RPC server: per-client dispatch and transport classes
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +An RPC service thread pool serves its ready transports in FIFO order,
> +one request per turn.  A peer with many connections (``nconnect``, a
> +deep NFSv4.1 slot table, a data mover with a thread per file) takes a
> +turn per connection, and a peer with one connection waits behind all
> +of them.
> +
> +With a classifier attached, the pool instead serves its *clients* round
> +robin: each client with work queued gets one request per round, however
> +many connections it holds.  Which transports form a client is decided
> +by a BPF program the administrator loads, once per accepted connection.
> +With no program loaded nothing changes.
> +
> +This document describes the model, how to install a classifier with
> +the ``svc-classify`` tool, what some class maps do, and how it works
> +underneath.
> +
> +Clients, classes and turns
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
> +
> +A *client* is a set of transports that share one turn.  Every service
> +(nfsd, lockd, the NFSv4 callback service) keeps its own clients, found
> +by *class* and network namespace, or by class, namespace and peer
> +address.
> +
> +The classifier returns a 32-bit class word for each accepted transport:
> +
> +``0``
> +    ``SVC_CLASS_NONE``: the transport stays on the service's *anonymous
> +    client*.
> +
> +``N``, 1 to 2^31 - 1
> +    one client for every transport of class ``N``.
> +
> +``N | SVC_CLASS_PER_ADDR``
> +    one client per peer address within class ``N``.  ``N`` may be 0, so
> +    ``SVC_CLASS_PER_ADDR`` alone means one client per peer address.
> +
> +``SVC_CLASS_PER_ADDR`` is bit 31.  ``svc-classify`` and this document
> +write a class word with the bit set as ``N+addr``; ``svc-classify``
> +also accepts ``addr`` for ``0+addr``.
> +
> +Dispatch rules:
> +
> +- A pool serves the clients that have transports queued round robin,
> +  one request per client per round.
> +- Within a client, transports are served in FIFO order, except that a
> +  transport needing a connection accepted, closed, or a TLS handshake
> +  run goes ahead of transports with data, though not two such turns in
> +  a row while data waits.
> +- A client's share of the pool does not grow with its connection count.
> +  A client with one connection and a client with thirty get the same
> +  number of turns while both have work queued.
> +
> +Things that follow from the rules and are easy to get wrong:
> +
> +- The anonymous client is one client.  Once any classifier is attached,
> +  every transport whose class is ``0`` shares a single turn with every
> +  other such transport of that service.  Within that one client the old
> +  FIFO order applies, so those peers share the turn in proportion to
> +  their connection counts.  A map that classifies only the hosts it
> +  cares about and leaves the rest at ``0`` gives "the rest" one turn
> +  in total (see example 5 below).
> +- Per-address clients ignore the port.  Only IPv4 and IPv6 peers can be
> +  keyed by address; a transport whose peer is anything else is left on
> +  the anonymous client.
> +- Listeners and UDP sockets are never classified; UDP traffic is served
> +  from the anonymous client.
> +- A transport keeps the class it was given when accepted.  Changing the
> +  map, or replacing or removing the classifier, affects connections
> +  accepted afterwards.  A connection that must be reclassified has to
> +  reconnect.
> +- nfsd has one service per network namespace, so its anonymous client
> +  is per namespace.  lockd and the NFSv4 callback service are one
> +  service for all namespaces; their anonymous clients span namespaces.
> +- With no classifier attached anywhere, the pool uses a single FIFO;
> +  the per-request cost of the feature is then a static branch on
> +  enqueue and one empty-queue test on dequeue.
> +  ``CONFIG_SUNRPC_BPF_CLASSIFY`` (default y) builds the hook; without
> +  it there is no classification.
> +
> +Installing a classifier
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +There is one tool to do it with: ``svc-classify``, in
> +``tools/net/sunrpc/svc-classify`` of the kernel source.  It carries the
> +classifier program inside the binary, attaches it, and manages the
> +class map by address prefix.  ``bpftool`` is not needed, and its
> +``struct_ops`` subcommands cannot be used in its place (see "How it
> +works").
> +

"There is one tool to do it with: ..."

The obviously LLM-written documentation gives me the Ick and I stopped
reading. There is also a lot of info in this doc that is not
particularly helpful, like "the things that follow from the rules and
are easy to get wrong".

If you want humans to actually read this, then it probably needs to be
written by a human. If you think the LLM slop is actually useful for
other LLMs, then maybe put those bits at the end in a clearly-
delineated section.

> +What you need
> +-------------
> +
> +- A kernel with ``CONFIG_SUNRPC_BPF_CLASSIFY`` (default y) and BTF:
> +  ``CONFIG_DEBUG_INFO_BTF``, and ``CONFIG_DEBUG_INFO_BTF_MODULES`` when
> +  ``sunrpc`` is a module.
> +- ``/sys/fs/bpf`` mounted (systemd mounts it).
> +- To build the tool: ``clang``, and the ``libelf`` and ``zlib``
> +  development files.  The tool builds the libbpf and bpftool it needs
> +  from the kernel source tree.
> +
> +Build and install the tool
> +--------------------------
> +
> +In the kernel source tree::
> +
> +    $ make -C tools/net/sunrpc/svc-classify
> +    # make -C tools/net/sunrpc/svc-classify install
> +
> +The binary goes to ``/usr/local/sbin/svc-classify`` (``prefix=3D`` and
> +``sbindir=3D`` override that).  At run time it needs only libelf and
> +zlib.
> +
> +Attach it
> +---------
> +
> +As root, in the network namespace the service runs in (on a host that
> +is the initial namespace; in a container, ``nsenter`` or
> +``ip netns exec`` into it first)::
> +
> +    # svc-classify load
> +    # svc-classify status
> +    loaded, link id 46, struct_ops map id 140
> +
> +The classifier is now attached to every RPC service in the namespace,
> +with an empty map: every connection accepted from now on returns class
> +``0`` and stays on the anonymous client, so nothing has changed yet.
> +One classifier per namespace: a second ``load`` is refused.
> +
> +Install the class map
> +---------------------
> +
> +Add one line per address prefix.  The longest matching prefix wins; a
> +peer that matches nothing gets class ``0``::
> +
> +    # svc-classify add 192.0.2.0/24 1
> +    # svc-classify add any addr
> +    # svc-classify list
> +    192.0.2.0/24 -> 1
> +    any -> 0+addr
> +
> +``PREFIX`` is ``a.b.c.d[/len]``, ``x:y::z[/len]``, ``any`` (every
> +address of either family), ``any4`` or ``any6``.  ``CLASS`` is ``N``
> +(one client for every peer that matches), ``N+addr`` (one client per
> +peer address, within class ``N``), ``addr`` (one client per peer
> +address, the same as ``0+addr``), or ``0`` (the anonymous client).
> +
> +Entries apply to connections accepted after they are added; to
> +reclassify existing connections, have the clients reconnect (restarting
> +the service does that for all of them).  ``svc-classify del PREFIX``
> +removes an entry.
> +
> +Check it
> +--------
> +
> +``svc-classify status`` and ``svc-classify list`` show the link and the
> +map.  The ``sunrpc:svc_xprt_dequeue`` tracepoint shows the class every
> +transport is dispatched as (see "Observing"), which is the check that
> +the map does what was meant.
> +
> +Change or remove it
> +-------------------
> +
> +- ``svc-classify add`` and ``del`` change the map at any time.
> +- ``svc-classify replace`` installs a new build of the tool's program
> +  on the attached link and keeps the map, provided the new build's map
> +  definition is unchanged; otherwise unload and load.
> +- ``svc-classify unload`` detaches the classifier.  Connections accepted
> +  afterwards are anonymous; when no classifier is attached in any
> +  namespace, the service is back on its single FIFO.
> +
> +Across reboots
> +--------------
> +
> +Nothing persists: the link and the map live in ``/sys/fs/bpf`` and are
> +gone at boot.  Run the ``load`` and ``add`` commands before the service
> +starts, for example from a unit ordered before ``nfs-server.service``::
> +
> +    [Unit]
> +    Description=3DRPC service transport classifier
> +    Before=3Dnfs-server.service
> +
> +    [Service]
> +    Type=3Doneshot
> +    RemainAfterExit=3Dyes
> +    ExecStart=3D/usr/local/sbin/svc-classify load
> +    ExecStart=3D/usr/local/sbin/svc-classify add 192.0.2.0/24 1
> +    ExecStart=3D/usr/local/sbin/svc-classify add any addr
> +    ExecStop=3D/usr/local/sbin/svc-classify unload
> +
> +    [Install]
> +    WantedBy=3Dnfs-server.service
> +
> +Loading after the service is up works too; it only misses the
> +connections already accepted.
> +
> +Examples
> +=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Each example gives the ``svc-classify add`` lines, the hosts they are
> +applied to, and the share of the pool each client gets while all of
> +them have work queued.
> +
> +1. Every host its own client
> +----------------------------
> +
> +::
> +
> +    # svc-classify add any addr
> +
> +Three hosts: one with eight connections, one with one, one with two.
> +Each host is a client, and each gets a third of the turns.  Without a
> +classifier they would be served in proportion to their connections,
> +8:1:2.
> +
> +2. A set of movers as one client, everyone else per host
> +--------------------------------------------------------
> +
> +::
> +
> +    # svc-classify add 192.0.2.0/24 1
> +    # svc-classify add any addr
> +
> +Three movers in ``192.0.2.0/24`` with four connections each, and two
> +other hosts, one with one connection and one with two.  The movers are
> +one client; each of the other hosts is a client of its own.  Each of
> +the three clients gets a third of the pool; the movers share theirs by
> +connection count, a ninth each.  Without a classifier the movers'
> +twelve connections would take twelve fifteenths of the pool and the
> +one-connection host one fifteenth.
> +
> +3. Two mover groups, one turn each
> +----------------------------------
> +
> +::
> +
> +    # svc-classify add 192.0.2.0/25 1
> +    # svc-classify add 192.0.2.128/25 2
> +    # svc-classify add any addr
> +
> +Two hosts in ``192.0.2.0/25`` and two in ``192.0.2.128/25``, four
> +connections each, and one other host with one connection.  Each group
> +is a client and the other host is a client: three clients, a third
> +each.  Within a group the two hosts split the group's third by
> +connection count, a sixth each.
> +
> +4. Per host inside a campus, the rest of the world as one client
> +----------------------------------------------------------------
> +
> +::
> +
> +    # svc-classify add 198.51.100.0/24 1+addr
> +    # svc-classify add any 2
> +
> +Two hosts in ``198.51.100.0/24`` and two hosts outside it.  Each campus
> +host is a client of its own (class 1, one client per address); the
> +outside hosts together are one client (class 2).  Three clients, a
> +third each; the outside hosts split their third by connection count.
> +
> +5. Leaving hosts unclassified
> +-----------------------------
> +
> +::
> +
> +    # svc-classify add 203.0.113.0/24 0
> +    # svc-classify add any addr
> +
> +Two hosts in ``203.0.113.0/24`` and two hosts elsewhere.  The two in
> +``203.0.113.0/24`` return ``0`` and so share the anonymous client, one
> +turn between them; the two elsewhere are a client each.  Three
> +clients, a third each; the anonymous pair split their third by
> +connection count.
> +
> +The common mistake is the map with only the movers in it::
> +
> +    # svc-classify add 192.0.2.0/24 1
> +
> +Three movers in ``192.0.2.0/24`` and two other hosts, one with one
> +connection and one with two.  There are exactly two clients: the
> +movers, and everyone else on the anonymous client.  The movers get
> +half the pool.  The other half goes to the two other hosts in
> +proportion to their connections, a sixth and a third of the pool.  Add
> +``any addr`` to serve them per host.
> +
> +6. IPv6
> +-------
> +
> +::
> +
> +    # svc-classify add 2001:db8:1::/48 1
> +    # svc-classify add any addr
> +
> +Entries are per family; ``any`` covers both families, ``any6`` IPv6
> +only.  Two hosts in ``2001:db8:1::/48`` and one host elsewhere: the two
> +are one client, the other is a client of its own, half the pool each.
> +
> +Observing
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +The ``sunrpc:svc_xprt_dequeue`` tracepoint reports the class of every
> +transport as it is dispatched::
> +
> +    svc_xprt_dequeue: server=3D127.0.0.1:3049 client=3D127.0.1.1:38209 x=
pt_id=3D1164 flags=3DBUSY|DATA|TEMP|CACHE_AUTH|LOCAL|CONG_CTRL class=3D1 wa=
keup-us=3D30 qtime-us=3D4
> +    svc_xprt_dequeue: server=3D127.0.0.1:3049 client=3D127.0.2.1:45965 x=
pt_id=3D1162 flags=3DBUSY|DATA|TEMP|CACHE_AUTH|LOCAL|CONG_CTRL class=3D0+ad=
dr wakeup-us=3D60 qtime-us=3D10
> +    svc_xprt_dequeue: server=3D[::1]:3049 client=3D[2001:db8:1::1]:44401=
 xpt_id=3D1152 flags=3DBUSY|DATA|TEMP|CACHE_AUTH|LOCAL|CONG_CTRL class=3D1 =
wakeup-us=3D62 qtime-us=3D7
> +    svc_xprt_dequeue: server=3D[::]:3049 client=3D(einval) xpt_id=3D2 fl=
ags=3DBUSY|CONN|CHNGBUF|LISTENER|CACHE_AUTH|CONG_CTRL|RPCB_UNREG class=3D0 =
wakeup-us=3D25 qtime-us=3D25
> +
> +``class=3D0`` is the anonymous client; ``+addr`` marks a per-address
> +client; listeners show ``class=3D0`` and ``LISTENER`` in their flags.
> +``bpftool link show`` lists the attached classifier's link, and
> +``bpftool map dump pinned /sys/fs/bpf/svc_classify/prefixes`` the map
> +with its raw keys.
> +
> +How it works
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +The classifier
> +--------------
> +
> +.. kernel-doc:: include/linux/sunrpc/svc.h
> +   :identifiers: svc_classifier
> +
> +The callback runs once per accepted transport, in process context,
> +under ``rcu_read_lock()``; sleepable programs are refused at load.
> +Only the base BPF helpers are available (map lookups, the usual).  The
> +program is handed the ``struct svc_xprt`` and may read its fields
> +directly:
> +
> +- ``xpt_remote`` and ``xpt_remotelen``: the peer address;
> +- ``xpt_local``: the address the connection arrived on;
> +- ``xpt_net``: the network namespace;
> +- ``xpt_server->sv_name``: which service, ``"nfsd"``, ``"lockd"``,
> +  ``"NFSv4 callback"``;
> +- ``xpt_class->xcl_name``: the transport class, ``"tcp"``, ``"rdma"``.
> +
> +A classifier applies to every service in its namespace.  A program that
> +wants to treat services differently reads ``xpt_server->sv_name``.
> +
> +The program ``svc-classify`` carries,
> +``tools/net/sunrpc/svc-classify/svc_classify.bpf.c``, is the prefix
> +classifier from the BPF selftests
> +(``tools/testing/selftests/bpf/progs/bpf_svc_classifier.c``).  Its one
> +map is an LPM trie keyed by ``{prefixlen, family, addr[16]}`` with
> +``prefixlen`` counting the family byte plus the address bits, and the
> +class word as the value; a miss returns ``0``.  Nothing else in the
> +program is specific to this policy.  A classifier keyed on the local
> +address, the service name, or anything else the ``svc_xprt`` shows is
> +the same program with a different lookup, and ``svc-classify replace``
> +installs a rebuilt one as long as its map definition is unchanged.
> +
> +Attaching
> +---------
> +
> +The classifier is a ``struct_ops`` map.  Creating its link attaches the
> +classifier to the network namespace of the task that creates the link:
> +
> +- one classifier per namespace; a second attach fails with ``-EBUSY``;
> +- ``BPF_LINK_UPDATE`` on the link replaces the program;
> +- closing or detaching the link, or unpinning its last reference,
> +  removes the classifier;
> +- a namespace that exits leaves its link attached to nothing;
> +  closing it is harmless.
> +
> +``svc-classify load`` creates the link with
> +``bpf_map__attach_struct_ops()`` and pins it, with the map, under
> +``/sys/fs/bpf/svc_classify`` (``-p DIR`` chooses another directory,
> +for a second namespace); ``replace`` is ``bpf_link__update_map()`` on
> +the pinned link; ``unload`` unpins both.
> +
> +``bpftool struct_ops`` (``register``, ``dump``, ``unregister``) resolves
> +the struct_ops type in the kernel's own BTF only, so when ``sunrpc`` is
> +a module those subcommands do not find ``svc_classifier`` maps, and
> +``register`` fails after creating the link.  Use ``svc-classify``.
> +
> +Limits
> +=3D=3D=3D=3D=3D=3D
> +
> +- A transport cannot move between clients; a client identity that is
> +  only known after the connection is accepted (an NFSv4.1 client id,
> +  say) cannot be used.  NFSv4.1 sessions over ``nconnect`` are one
> +  client by peer address.
> +- RDMA transports are classified like TCP, by the peer address of the
> +  connection; UDP is not classified.
> +- The cost with no classifier attached is a static branch on enqueue
> +  and one empty-queue test on dequeue.  With one attached, dispatch
> +  takes two or three more lock-free queue operations per request than
> +  before: the client's queue, the pool's queue of clients, and a
> +  requeue when the client has more.

--=20
Jeff Layton <jlayton@kernel.org>
