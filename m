Received: from mail-oo1-f53.google.com (mail-oo1-f53.google.com [209.85.161.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08A4F3822BF
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403195; cv=none; b=jFNwckio5ZwmfdUODhxBevPqWHLU7n9KFnLqzon7MpHqxNl9kUV6w3H/7QB73bCYQ3CMTq4IOh+Q3SCT75HzPYwo3glk7GOG79Ac1ptZFvyZPOKHzwyGhSDNLaTC35xwCnpzDbiAK8MxnbSrr87ZRsXGRFxLoW5uptn/ZZ46i5Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403195; c=relaxed/simple;
	bh=MMofOCiLzdeGY0J60CJxlx3I61b9RNhDsbDlrDfuxhc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=V/aXWrWLXhAEY6YLPJH0Q0IHJvC3hFTWTlME13ndoxN/hibFdSLqCzShBTlrOt3dvCAD9BSYrWJHjfjstn51Bjc5fmX4xHipoMmiMYWvD2Kr99k47ETdGhYiukQk6aE/Qb/oxquItwNQSjlStnURQE/yKho5EDkxSHA2KQEQ81A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=MRBjQKjD; arc=none smtp.client-ip=209.85.161.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="MRBjQKjD"
Received: by mail-oo1-f53.google.com with SMTP id 006d021491bc7-6ddfe39131eso1450657eaf.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403192; x=1792007992; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=pOWdZNNoKM1iSSyp4krbLURKcF0fsENweX+Jn/eL4iM=;
        b=MRBjQKjD3kp6ML8Os+064+LVgEj5xu8q7CCAUP+/s0tb866v4+ZsJRqWhluj0SPehA
         mM41uxzsFIva7jMs1ropSAOcWgsncDDyBz6DKf+ezaMV/1o5FdsXdvtznUgxqEAwNr8a
         cPrsMQ3rQtRjCFty+UQXQPkedSQvEex78CHhOPgflNWSPQPBujyBYDtoBGuPVrnSmZNx
         bZMp/Dd+T/k3QlfuK4eIlZWymHT7GsMEtCgsnbj1n4v6+lTOayLG+nNynQzWl+PhYVJG
         eVtYVTvkTi9HIdViVC+1g/ex8tYMvqhG22dosnwFR9LrZEoUVZniDRtCEhpFnxsmy18+
         cMkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403192; x=1792007992;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=pOWdZNNoKM1iSSyp4krbLURKcF0fsENweX+Jn/eL4iM=;
        b=WU59+RV0Y6xWkdnRkWk0vXdYKGyAL3UzrsKum+n2DOIo4yUcNNM2J9w9jQthXFljhL
         9/8FHiTcHU1bjsfQjqFw6Zxcs3El58DBMP3c9OlojJiOuZgKDV9vr6l7VIzuAPi7IKyM
         +md0lXuCpzcjUsBdurpDI/T6FoSknTcLJOUpo0JmvmC8WFcdfbhLZRQE01BOp99vQub0
         Kkt26XiCIgQPorjGaH8Qz/P0UdBl0ScFkZuN9XRtQBm4CDwmkl1xxR3qu3TvSxC8AiKY
         BScXQu2D1AHtIXn8qZBHcAM4FQXXGHRkbTk6wgqNNEfvW2oSl08eKa+vqJKPurFJEYFD
         pbKw==
X-Gm-Message-State: AFuF++lIggOZSOidJbP8miD93QHkMwPcGJYEufyakquLDZzDzYB3Pbu4
	2OXsr2gz7ftRpvasZAuvAGbtRBaZHSPUqt5/KQSLS0+SnJ4rqb73bcUcyckMnM+RTa4=
X-Gm-Gg: AYBFou2BuU/TOHjLj13kTf8jxOW32Vy12xarakUKfZjmwdu1E/iSNDAOka6XhRHXIJo
	pwKaZ9rBRpB1o9SEBtL0zTqKmcqCJxVcFdSoWlYqTjrH44y+fHfASSoYz9/0PMs5N/qYTmw8Hel
	+3lBRxMCQzCrVPAm9ceT54030K4Snnd75zW+jtTL3dYfWvjlmAQcDVLDZVa2s5i0GnL/SBeVPs1
	ZulGfj0jwnNCL6pjla9SUUfknM5uKGAlLR0fgBoJ4r/+KyosfF7Eu/I1weJ2uNMlwjLYLOEQq1g
	KQ1HJBf6yUlbRrhOznjNbE2A/Z7Xz6C71pKJQXJpX25fTaBxwelgAX1PKdK5sQH9FFYHodsx577
	oCVXX9RfPCpve6DE3+F7Zi8tLfneeg7LK8Zb9TKicEm8CJ/L//wLKH+EYkuWMVKwPc9YAkiTb/t
	bgKWeoJD1ffvhHw1/tj/GTQZy/qWmLP8AT3SNyPHvn1uc9ifu3B10fPqpj6m7LFNdLvLQpwjlIi
	wULGj1gtRzJCQFFsKjU0Le7SzU=
X-Received: by 2002:a05:6820:818c:b0:6e2:3d8b:a007 with SMTP id 006d021491bc7-6e7a62b89damr3067068eaf.32.1791403191183;
        Wed, 07 Oct 2026 12:59:51 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:50 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 9/9] Documentation: describe RPC server transport classes and the BPF classifier
Date: Wed,  7 Oct 2026 15:59:34 -0400
Message-ID: <ef239ae64ae4379ad9a55d4fc3642d659dad4ef8.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

Dispatch round-robin across clients changes how a service shares its
threads, and the classes come from a BPF program the administrator
loads, so the administrator needs the model, the class word, and the
procedure.  Add a page with those: install a classifier with
svc-classify (build, attach, fill the map, check, change, remove, keep
across reboots), six class maps and the share each gives its clients,
the tracepoint that shows the class, and how the hook, the program and
the attach model work underneath.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 Documentation/filesystems/nfs/index.rst       |   1 +
 .../filesystems/nfs/rpc-server-clients.rst    | 394 ++++++++++++++++++
 2 files changed, 395 insertions(+)
 create mode 100644 Documentation/filesystems/nfs/rpc-server-clients.rst

diff --git a/Documentation/filesystems/nfs/index.rst b/Documentation/filesystems/nfs/index.rst
index a29a212b5b4d..57a61ce0533d 100644
--- a/Documentation/filesystems/nfs/index.rst
+++ b/Documentation/filesystems/nfs/index.rst
@@ -16,3 +16,4 @@ NFS
    nfsd-io-modes
    knfsd-stats
    reexport
+   rpc-server-clients
diff --git a/Documentation/filesystems/nfs/rpc-server-clients.rst b/Documentation/filesystems/nfs/rpc-server-clients.rst
new file mode 100644
index 000000000000..b08351a88314
--- /dev/null
+++ b/Documentation/filesystems/nfs/rpc-server-clients.rst
@@ -0,0 +1,394 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+======================================================
+RPC server: per-client dispatch and transport classes
+======================================================
+
+An RPC service thread pool serves its ready transports in FIFO order,
+one request per turn.  A peer with many connections (``nconnect``, a
+deep NFSv4.1 slot table, a data mover with a thread per file) takes a
+turn per connection, and a peer with one connection waits behind all
+of them.
+
+With a classifier attached, the pool instead serves its *clients* round
+robin: each client with work queued gets one request per round, however
+many connections it holds.  Which transports form a client is decided
+by a BPF program the administrator loads, once per accepted connection.
+With no program loaded nothing changes.
+
+This document describes the model, how to install a classifier with
+the ``svc-classify`` tool, what some class maps do, and how it works
+underneath.
+
+Clients, classes and turns
+==========================
+
+A *client* is a set of transports that share one turn.  Every service
+(nfsd, lockd, the NFSv4 callback service) keeps its own clients, found
+by *class* and network namespace, or by class, namespace and peer
+address.
+
+The classifier returns a 32-bit class word for each accepted transport:
+
+``0``
+    ``SVC_CLASS_NONE``: the transport stays on the service's *anonymous
+    client*.
+
+``N``, 1 to 2^31 - 1
+    one client for every transport of class ``N``.
+
+``N | SVC_CLASS_PER_ADDR``
+    one client per peer address within class ``N``.  ``N`` may be 0, so
+    ``SVC_CLASS_PER_ADDR`` alone means one client per peer address.
+
+``SVC_CLASS_PER_ADDR`` is bit 31.  ``svc-classify`` and this document
+write a class word with the bit set as ``N+addr``; ``svc-classify``
+also accepts ``addr`` for ``0+addr``.
+
+Dispatch rules:
+
+- A pool serves the clients that have transports queued round robin,
+  one request per client per round.
+- Within a client, transports are served in FIFO order, except that a
+  transport needing a connection accepted, closed, or a TLS handshake
+  run goes ahead of transports with data, though not two such turns in
+  a row while data waits.
+- A client's share of the pool does not grow with its connection count.
+  A client with one connection and a client with thirty get the same
+  number of turns while both have work queued.
+
+Things that follow from the rules and are easy to get wrong:
+
+- The anonymous client is one client.  Once any classifier is attached,
+  every transport whose class is ``0`` shares a single turn with every
+  other such transport of that service.  Within that one client the old
+  FIFO order applies, so those peers share the turn in proportion to
+  their connection counts.  A map that classifies only the hosts it
+  cares about and leaves the rest at ``0`` gives "the rest" one turn
+  in total (see example 5 below).
+- Per-address clients ignore the port.  Only IPv4 and IPv6 peers can be
+  keyed by address; a transport whose peer is anything else is left on
+  the anonymous client.
+- Listeners and UDP sockets are never classified; UDP traffic is served
+  from the anonymous client.
+- A transport keeps the class it was given when accepted.  Changing the
+  map, or replacing or removing the classifier, affects connections
+  accepted afterwards.  A connection that must be reclassified has to
+  reconnect.
+- nfsd has one service per network namespace, so its anonymous client
+  is per namespace.  lockd and the NFSv4 callback service are one
+  service for all namespaces; their anonymous clients span namespaces.
+- With no classifier attached anywhere, the pool uses a single FIFO;
+  the per-request cost of the feature is then a static branch on
+  enqueue and one empty-queue test on dequeue.
+  ``CONFIG_SUNRPC_BPF_CLASSIFY`` (default y) builds the hook; without
+  it there is no classification.
+
+Installing a classifier
+=======================
+
+There is one tool to do it with: ``svc-classify``, in
+``tools/net/sunrpc/svc-classify`` of the kernel source.  It carries the
+classifier program inside the binary, attaches it, and manages the
+class map by address prefix.  ``bpftool`` is not needed, and its
+``struct_ops`` subcommands cannot be used in its place (see "How it
+works").
+
+What you need
+-------------
+
+- A kernel with ``CONFIG_SUNRPC_BPF_CLASSIFY`` (default y) and BTF:
+  ``CONFIG_DEBUG_INFO_BTF``, and ``CONFIG_DEBUG_INFO_BTF_MODULES`` when
+  ``sunrpc`` is a module.
+- ``/sys/fs/bpf`` mounted (systemd mounts it).
+- To build the tool: ``clang``, and the ``libelf`` and ``zlib``
+  development files.  The tool builds the libbpf and bpftool it needs
+  from the kernel source tree.
+
+Build and install the tool
+--------------------------
+
+In the kernel source tree::
+
+    $ make -C tools/net/sunrpc/svc-classify
+    # make -C tools/net/sunrpc/svc-classify install
+
+The binary goes to ``/usr/local/sbin/svc-classify`` (``prefix=`` and
+``sbindir=`` override that).  At run time it needs only libelf and
+zlib.
+
+Attach it
+---------
+
+As root, in the network namespace the service runs in (on a host that
+is the initial namespace; in a container, ``nsenter`` or
+``ip netns exec`` into it first)::
+
+    # svc-classify load
+    # svc-classify status
+    loaded, link id 46, struct_ops map id 140
+
+The classifier is now attached to every RPC service in the namespace,
+with an empty map: every connection accepted from now on returns class
+``0`` and stays on the anonymous client, so nothing has changed yet.
+One classifier per namespace: a second ``load`` is refused.
+
+Install the class map
+---------------------
+
+Add one line per address prefix.  The longest matching prefix wins; a
+peer that matches nothing gets class ``0``::
+
+    # svc-classify add 192.0.2.0/24 1
+    # svc-classify add any addr
+    # svc-classify list
+    192.0.2.0/24 -> 1
+    any -> 0+addr
+
+``PREFIX`` is ``a.b.c.d[/len]``, ``x:y::z[/len]``, ``any`` (every
+address of either family), ``any4`` or ``any6``.  ``CLASS`` is ``N``
+(one client for every peer that matches), ``N+addr`` (one client per
+peer address, within class ``N``), ``addr`` (one client per peer
+address, the same as ``0+addr``), or ``0`` (the anonymous client).
+
+Entries apply to connections accepted after they are added; to
+reclassify existing connections, have the clients reconnect (restarting
+the service does that for all of them).  ``svc-classify del PREFIX``
+removes an entry.
+
+Check it
+--------
+
+``svc-classify status`` and ``svc-classify list`` show the link and the
+map.  The ``sunrpc:svc_xprt_dequeue`` tracepoint shows the class every
+transport is dispatched as (see "Observing"), which is the check that
+the map does what was meant.
+
+Change or remove it
+-------------------
+
+- ``svc-classify add`` and ``del`` change the map at any time.
+- ``svc-classify replace`` installs a new build of the tool's program
+  on the attached link and keeps the map, provided the new build's map
+  definition is unchanged; otherwise unload and load.
+- ``svc-classify unload`` detaches the classifier.  Connections accepted
+  afterwards are anonymous; when no classifier is attached in any
+  namespace, the service is back on its single FIFO.
+
+Across reboots
+--------------
+
+Nothing persists: the link and the map live in ``/sys/fs/bpf`` and are
+gone at boot.  Run the ``load`` and ``add`` commands before the service
+starts, for example from a unit ordered before ``nfs-server.service``::
+
+    [Unit]
+    Description=RPC service transport classifier
+    Before=nfs-server.service
+
+    [Service]
+    Type=oneshot
+    RemainAfterExit=yes
+    ExecStart=/usr/local/sbin/svc-classify load
+    ExecStart=/usr/local/sbin/svc-classify add 192.0.2.0/24 1
+    ExecStart=/usr/local/sbin/svc-classify add any addr
+    ExecStop=/usr/local/sbin/svc-classify unload
+
+    [Install]
+    WantedBy=nfs-server.service
+
+Loading after the service is up works too; it only misses the
+connections already accepted.
+
+Examples
+========
+
+Each example gives the ``svc-classify add`` lines, the hosts they are
+applied to, and the share of the pool each client gets while all of
+them have work queued.
+
+1. Every host its own client
+----------------------------
+
+::
+
+    # svc-classify add any addr
+
+Three hosts: one with eight connections, one with one, one with two.
+Each host is a client, and each gets a third of the turns.  Without a
+classifier they would be served in proportion to their connections,
+8:1:2.
+
+2. A set of movers as one client, everyone else per host
+--------------------------------------------------------
+
+::
+
+    # svc-classify add 192.0.2.0/24 1
+    # svc-classify add any addr
+
+Three movers in ``192.0.2.0/24`` with four connections each, and two
+other hosts, one with one connection and one with two.  The movers are
+one client; each of the other hosts is a client of its own.  Each of
+the three clients gets a third of the pool; the movers share theirs by
+connection count, a ninth each.  Without a classifier the movers'
+twelve connections would take twelve fifteenths of the pool and the
+one-connection host one fifteenth.
+
+3. Two mover groups, one turn each
+----------------------------------
+
+::
+
+    # svc-classify add 192.0.2.0/25 1
+    # svc-classify add 192.0.2.128/25 2
+    # svc-classify add any addr
+
+Two hosts in ``192.0.2.0/25`` and two in ``192.0.2.128/25``, four
+connections each, and one other host with one connection.  Each group
+is a client and the other host is a client: three clients, a third
+each.  Within a group the two hosts split the group's third by
+connection count, a sixth each.
+
+4. Per host inside a campus, the rest of the world as one client
+----------------------------------------------------------------
+
+::
+
+    # svc-classify add 198.51.100.0/24 1+addr
+    # svc-classify add any 2
+
+Two hosts in ``198.51.100.0/24`` and two hosts outside it.  Each campus
+host is a client of its own (class 1, one client per address); the
+outside hosts together are one client (class 2).  Three clients, a
+third each; the outside hosts split their third by connection count.
+
+5. Leaving hosts unclassified
+-----------------------------
+
+::
+
+    # svc-classify add 203.0.113.0/24 0
+    # svc-classify add any addr
+
+Two hosts in ``203.0.113.0/24`` and two hosts elsewhere.  The two in
+``203.0.113.0/24`` return ``0`` and so share the anonymous client, one
+turn between them; the two elsewhere are a client each.  Three
+clients, a third each; the anonymous pair split their third by
+connection count.
+
+The common mistake is the map with only the movers in it::
+
+    # svc-classify add 192.0.2.0/24 1
+
+Three movers in ``192.0.2.0/24`` and two other hosts, one with one
+connection and one with two.  There are exactly two clients: the
+movers, and everyone else on the anonymous client.  The movers get
+half the pool.  The other half goes to the two other hosts in
+proportion to their connections, a sixth and a third of the pool.  Add
+``any addr`` to serve them per host.
+
+6. IPv6
+-------
+
+::
+
+    # svc-classify add 2001:db8:1::/48 1
+    # svc-classify add any addr
+
+Entries are per family; ``any`` covers both families, ``any6`` IPv6
+only.  Two hosts in ``2001:db8:1::/48`` and one host elsewhere: the two
+are one client, the other is a client of its own, half the pool each.
+
+Observing
+=========
+
+The ``sunrpc:svc_xprt_dequeue`` tracepoint reports the class of every
+transport as it is dispatched::
+
+    svc_xprt_dequeue: server=127.0.0.1:3049 client=127.0.1.1:38209 xpt_id=1164 flags=BUSY|DATA|TEMP|CACHE_AUTH|LOCAL|CONG_CTRL class=1 wakeup-us=30 qtime-us=4
+    svc_xprt_dequeue: server=127.0.0.1:3049 client=127.0.2.1:45965 xpt_id=1162 flags=BUSY|DATA|TEMP|CACHE_AUTH|LOCAL|CONG_CTRL class=0+addr wakeup-us=60 qtime-us=10
+    svc_xprt_dequeue: server=[::1]:3049 client=[2001:db8:1::1]:44401 xpt_id=1152 flags=BUSY|DATA|TEMP|CACHE_AUTH|LOCAL|CONG_CTRL class=1 wakeup-us=62 qtime-us=7
+    svc_xprt_dequeue: server=[::]:3049 client=(einval) xpt_id=2 flags=BUSY|CONN|CHNGBUF|LISTENER|CACHE_AUTH|CONG_CTRL|RPCB_UNREG class=0 wakeup-us=25 qtime-us=25
+
+``class=0`` is the anonymous client; ``+addr`` marks a per-address
+client; listeners show ``class=0`` and ``LISTENER`` in their flags.
+``bpftool link show`` lists the attached classifier's link, and
+``bpftool map dump pinned /sys/fs/bpf/svc_classify/prefixes`` the map
+with its raw keys.
+
+How it works
+============
+
+The classifier
+--------------
+
+.. kernel-doc:: include/linux/sunrpc/svc.h
+   :identifiers: svc_classifier
+
+The callback runs once per accepted transport, in process context,
+under ``rcu_read_lock()``; sleepable programs are refused at load.
+Only the base BPF helpers are available (map lookups, the usual).  The
+program is handed the ``struct svc_xprt`` and may read its fields
+directly:
+
+- ``xpt_remote`` and ``xpt_remotelen``: the peer address;
+- ``xpt_local``: the address the connection arrived on;
+- ``xpt_net``: the network namespace;
+- ``xpt_server->sv_name``: which service, ``"nfsd"``, ``"lockd"``,
+  ``"NFSv4 callback"``;
+- ``xpt_class->xcl_name``: the transport class, ``"tcp"``, ``"rdma"``.
+
+A classifier applies to every service in its namespace.  A program that
+wants to treat services differently reads ``xpt_server->sv_name``.
+
+The program ``svc-classify`` carries,
+``tools/net/sunrpc/svc-classify/svc_classify.bpf.c``, is the prefix
+classifier from the BPF selftests
+(``tools/testing/selftests/bpf/progs/bpf_svc_classifier.c``).  Its one
+map is an LPM trie keyed by ``{prefixlen, family, addr[16]}`` with
+``prefixlen`` counting the family byte plus the address bits, and the
+class word as the value; a miss returns ``0``.  Nothing else in the
+program is specific to this policy.  A classifier keyed on the local
+address, the service name, or anything else the ``svc_xprt`` shows is
+the same program with a different lookup, and ``svc-classify replace``
+installs a rebuilt one as long as its map definition is unchanged.
+
+Attaching
+---------
+
+The classifier is a ``struct_ops`` map.  Creating its link attaches the
+classifier to the network namespace of the task that creates the link:
+
+- one classifier per namespace; a second attach fails with ``-EBUSY``;
+- ``BPF_LINK_UPDATE`` on the link replaces the program;
+- closing or detaching the link, or unpinning its last reference,
+  removes the classifier;
+- a namespace that exits leaves its link attached to nothing;
+  closing it is harmless.
+
+``svc-classify load`` creates the link with
+``bpf_map__attach_struct_ops()`` and pins it, with the map, under
+``/sys/fs/bpf/svc_classify`` (``-p DIR`` chooses another directory,
+for a second namespace); ``replace`` is ``bpf_link__update_map()`` on
+the pinned link; ``unload`` unpins both.
+
+``bpftool struct_ops`` (``register``, ``dump``, ``unregister``) resolves
+the struct_ops type in the kernel's own BTF only, so when ``sunrpc`` is
+a module those subcommands do not find ``svc_classifier`` maps, and
+``register`` fails after creating the link.  Use ``svc-classify``.
+
+Limits
+======
+
+- A transport cannot move between clients; a client identity that is
+  only known after the connection is accepted (an NFSv4.1 client id,
+  say) cannot be used.  NFSv4.1 sessions over ``nconnect`` are one
+  client by peer address.
+- RDMA transports are classified like TCP, by the peer address of the
+  connection; UDP is not classified.
+- The cost with no classifier attached is a static branch on enqueue
+  and one empty-queue test on dequeue.  With one attached, dispatch
+  takes two or three more lock-free queue operations per request than
+  before: the client's queue, the pool's queue of clients, and a
+  requeue when the client has more.
-- 
2.53.0

