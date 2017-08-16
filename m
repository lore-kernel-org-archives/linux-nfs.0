Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:37478 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752494AbdHPAvt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Aug 2017 20:51:49 -0400
Received: by mail-lf0-f53.google.com with SMTP id m86so10132552lfi.4
        for <linux-nfs@vger.kernel.org>; Tue, 15 Aug 2017 17:51:48 -0700 (PDT)
MIME-Version: 1.0
From: Bennett Amodio <bamodio@purestorage.com>
Date: Tue, 15 Aug 2017 17:51:46 -0700
Message-ID: <CAKk7tABaTxA102tUHEuYyC8rtbNDjzHX6MdVcCkTy_26yfVkvA@mail.gmail.com>
Subject: [RFC v3 2/2] SUNRPC: Mask XIDs to prevent replay cache collision
To: linux-nfs@vger.kernel.org
Cc: anna.schumaker@netapp.com, trond.myklebust@primarydata.com,
        Igor Ostrovsky <igor@purestorage.com>,
        Vas Chellappa <vas@purestorage.com>,
        Jui-Yu Chang <juchang@purestorage.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Modify transport behavior so transports mask their XIDs. xid_mask is
the mask which clears the top several bits. masked_xid is the ID
(unique to each transport which belongs to the same NFS mount).

We also removed xprt_init_xid, since the XID is now initialized
through rpc_create (and passed in via xprtargs). Since the
initialization of xid, masked_id and xid_mask occur in
xprt_create_transport, this should work with rpcrdma as well.

Signed-off-by: Bennett Amodio <bamodio@purestorage.com>
---
 include/linux/sunrpc/xprt.h |  5 +++++
 net/sunrpc/clnt.c           |  8 ++++++++
 net/sunrpc/xprt.c           | 14 ++++++--------
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index eab1c74..c80edc4 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -207,6 +207,8 @@ struct rpc_xprt {
  * Multipath
  */
  struct list_head xprt_switch;
+ u32 masked_id;
+ u32 xid_mask;

  /*
  * Connection of transports
@@ -306,6 +308,9 @@ struct xprt_create {
  struct svc_xprt *bc_xprt; /* NFSv4.1 backchannel */
  struct rpc_xprt_switch *bc_xps;
  unsigned int flags;
+ u32 transport_id;
+ u32 bitmask_len;
+ u32 init_xid;
 };

 struct xprt_class {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bb39f07..8556370 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -520,6 +520,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *arg=
s)
  .addrlen =3D args->addrsize,
  .servername =3D args->servername,
  .bc_xprt =3D args->bc_xprt,
+ .init_xid =3D prandom_u32(),
  };
  char servername[48];
  struct rpc_clnt *clnt;
@@ -572,6 +573,12 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *ar=
gs)
  xprtargs.servername =3D servername;
  }

+ if (args->nconnect)
+ xprtargs.bitmask_len =3D fls(args->nconnect - 1);
+ else
+ xprtargs.bitmask_len =3D 0;
+ xprtargs.transport_id =3D 0;
+
  xprt =3D xprt_create_transport(&xprtargs);
  if (IS_ERR(xprt))
  return (struct rpc_clnt *)xprt;
@@ -591,6 +598,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *arg=
s)
  return clnt;

  for (i =3D 0; i < args->nconnect - 1; i++) {
+ xprtargs.transport_id +=3D 1;
  if (rpc_clnt_add_xprt(clnt, &xprtargs, NULL, NULL) < 0)
  break;
  }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3e63c5e..49fd56e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1231,12 +1231,7 @@ void xprt_retry_reserve(struct rpc_task *task)

 static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
 {
- return (__force __be32)xprt->xid++;
-}
-
-static inline void xprt_init_xid(struct rpc_xprt *xprt)
-{
- xprt->xid =3D prandom_u32();
+ return (__force __be32) (xprt->xid++ & xprt->xid_mask) | xprt->masked_id;
 }

 static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt=
)
@@ -1334,8 +1329,6 @@ static void xprt_init(struct rpc_xprt *xprt,
struct net *net)
  rpc_init_priority_wait_queue(&xprt->sending, "xprt_sending");
  rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");

- xprt_init_xid(xprt);
-
  xprt->xprt_net =3D get_net(net);
 }

@@ -1367,6 +1360,11 @@ struct rpc_xprt *xprt_create_transport(struct
xprt_create *args)
  -PTR_ERR(xprt));
  goto out;
  }
+
+ xprt->xid_mask =3D 0xffffffff >> args->bitmask_len;
+ xprt->masked_id =3D args->transport_id << (32 - args->bitmask_len);
+ xprt->xid =3D args->init_xid;
+
  if (args->flags & XPRT_CREATE_NO_IDLE_TIMEOUT)
  xprt->idle_timeout =3D 0;
  INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
--=20
1.9.1

On Tue, Aug 15, 2017 at 5:48 PM, Bennett Amodio <bamodio@purestorage.com> w=
rote:
> Enable nconnect mount option and multipathing behavior for NFSv3 and NFSv=
4.
>
> Signed-off-by: Jui-Yu Chang <juchang@purestorage.com>
> ---
>  fs/nfs/client.c     | 3 +++
>  fs/nfs/nfs4client.c | 2 +-
>  2 files changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 08baa66..8d11a11 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -653,6 +653,9 @@ static int nfs_init_server(struct nfs_server *server,
>   struct nfs_client *clp;
>   int error;
>
> + if (data->nfs_server.protocol =3D=3D XPRT_TRANSPORT_TCP)
> + cl_init.nconnect =3D data->nfs_server.nconnect;
> +
>   nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
>   data->timeo, data->retrans);
>   if (data->flags & NFS_MOUNT_NORESVPORT)
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index f11dec1..6ef1baa 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -849,7 +849,7 @@ static int nfs4_set_client(struct nfs_server *server,
>   };
>   struct nfs_client *clp;
>
> - if (minorversion > 0 && proto =3D=3D XPRT_TRANSPORT_TCP)
> + if (proto =3D=3D XPRT_TRANSPORT_TCP)
>   cl_init.nconnect =3D nconnect;
>   if (server->flags & NFS_MOUNT_NORESVPORT)
>   set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
> --
> 1.9.1
>
> On Tue, Aug 15, 2017 at 5:46 PM, Bennett Amodio <bamodio@purestorage.com>=
 wrote:
>> After seeing Trond=E2=80=99s patches for NFS multipathing on NFSv4.1, we
>> decided to try using the same concept for NFSv3/4.  The primary issue
>> we identified was XID collision in the duplicate request cache (replay
>> cache) for NFSv3/4.  In NFSv3/4, entries are hashed based on XID
>> instead of the slot ID and sequence ID that NFSv4.1 uses.  Since the
>> XIDs are generated by the RPC transports, and Trond=E2=80=99s patches cr=
eate
>> multiple transports for multipathing, different transports can end up
>> using an overlapping set of XIDs.
>>
>>
>> To fix this, we apply a mask to XIDs. Each transport is constrained to
>> its own segment of the total XID range, and they can never overlap.
>> In terms of loss of entropy, by masking out just enough bits from the
>> XID, we are convinced that the probability of XID wraparound or
>> collision on NFS client restart has not increased to a problematic
>> level (so long as the RPCs are distributed round-robin, as in Trond=E2=
=80=99s
>> patches).
>>
>>
>> We tested multipathing out and discovered that it enables NFS to get
>> more bandwidth on a bonded interface (instead of using only one
>> physical link, it can use multiple).  Specifically, we tested on a
>> setup where the client was connected to the server via 4 bonded 10Gb/s
>> links.  Without multipathing, the client could only achieve 10Gb/s
>> (using one physical link).  With multipathing, the client was able to
>> achieve a maximum of close to 40Gb/s.
>>
>>
>> However, although the maximum performance was close to 40Gb/s,
>> achieving an average throughput of even 30Gb/s required many
>> connections.  The performance of individual trials had a high
>> variance.  We traced this uneven performance to colliding network
>> paths.  With round-robin distribution of RPCs, no single TCP
>> connection can exceed the performance of the slowest one.  If the
>> connections are distributed unevenly across network paths, some
>> connections can bottleneck others.  To solve this problem, we are
>> currently working on patches to provide load-balancing as an
>> alternative to round-robin for distributing RPCs.
>>
>>
>> To use these patches, you first have to apply Trond's 5 patches
>> (Available at https://www.spinics.net/lists/linux-nfs/msg63368.html).
>> Let us know what you think or if you have any ideas for improving
>> this.
>>
>>
>> Jui-Yu Chang (1):
>>   NFS: Allow multiple connections to NFSv3 and NFSv4.0 servers
>>
>> Bennett Amodio (1):
>>   SUNRPC: Mask XIDs to prevent replay cache collision
>>
>>  fs/nfs/client.c             |  3 +++
>>  fs/nfs/nfs4client.c         |  2 +-
>>  include/linux/sunrpc/xprt.h |  5 +++++
>>  net/sunrpc/clnt.c           |  8 ++++++++
>>  net/sunrpc/xprt.c           | 14 ++++++--------
>>  5 files changed, 23 insertions(+), 9 deletions(-)
>>
>> --
>> 1.9.1
