Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f176.google.com ([209.85.128.176]:34761 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab3HTN6t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Aug 2013 09:58:49 -0400
Received: by mail-ve0-f176.google.com with SMTP id b10so307557vea.21
        for <linux-nfs@vger.kernel.org>; Tue, 20 Aug 2013 06:58:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1376495823.29258.15.camel@leira.trondhjem.org>
References: <1376418952-12481-1-git-send-email-Trond.Myklebust@netapp.com>
	<20130814153139.GJ17781@fieldses.org>
	<1376495823.29258.15.camel@leira.trondhjem.org>
Date: Tue, 20 Aug 2013 09:58:48 -0400
Message-ID: <CAHVgHyW_WWdHepnDLuGeQCVnp6kijcddMZhxDURXyr72o3EMQA@mail.gmail.com>
Subject: Re: [PATCH 01/10] NFSv4: Add tracepoints for debugging state
 management problems
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me as well. I like the division trace points and NFS
operations. This should be very useful. I'm curious to see the
performance hit.

-->Andy

On Wed, Aug 14, 2013 at 11:57 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2013-08-14 at 11:31 -0400, J. Bruce Fields wrote:
>> On Tue, Aug 13, 2013 at 02:35:43PM -0400, Trond Myklebust wrote:
>> > Set up basic tracepoints for debugging client id creation/destruction
>> > and session creation/destruction.
>>
>> Looks good to me. Dumb questions, just out of curiosity:
>>
>>       - Some of these are followed by dprintk's with similar
>>         information.  Is it worth keeping those, or could they be
>>         phased out at some point?
>
> I'd like to phase out the dprintks over time.
>
>>       - Some of them are paired with an rpc_call_sync.  What do these
>>         get you that wouldn't get out of wireshark with a suitable
>>         filter?
>
> The tracepoints give you the ability to do more sophisticated dynamic
> tracing using systemtap or lttng.
>
> The ringbuffer used by ftrace means that the overhead is relatively
> small: you're not spamming the syslog all the time. Furthermore, ftrace
> does support some simple filters. I'm therefore thinking that some
> sysadmins might want to consider enabling some of these tracepoints
> permanently on their systems in order to be able to post-mortem state
> recovery issues following networking outages and/or server reboots.
>
> Cheers
>   Trond
>
>> --b.
>>
>> >
>> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> > ---
>> >  fs/nfs/Makefile    |   3 +-
>> >  fs/nfs/nfs4proc.c  |   9 +++
>> >  fs/nfs/nfs4trace.c |  10 +++
>> >  fs/nfs/nfs4trace.h | 205 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>> >  4 files changed, 226 insertions(+), 1 deletion(-)
>> >  create mode 100644 fs/nfs/nfs4trace.c
>> >  create mode 100644 fs/nfs/nfs4trace.h
>> >
>> > diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
>> > index e0bb048..71ba4c2 100644
>> > --- a/fs/nfs/Makefile
>> > +++ b/fs/nfs/Makefile
>> > @@ -21,7 +21,8 @@ nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
>> >  obj-$(CONFIG_NFS_V4) += nfsv4.o
>> >  nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
>> >       delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
>> > -     nfs4namespace.o nfs4getroot.o nfs4client.o dns_resolve.o
>> > +     nfs4namespace.o nfs4getroot.o nfs4client.o dns_resolve.o \
>> > +     nfs4trace.c
>> >  nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
>> >  nfsv4-$(CONFIG_SYSCTL)     += nfs4sysctl.o
>> >  nfsv4-$(CONFIG_NFS_V4_1)   += nfs4session.o pnfs.o pnfs_dev.o
>> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> > index a187f4d..3a55f24 100644
>> > --- a/fs/nfs/nfs4proc.c
>> > +++ b/fs/nfs/nfs4proc.c
>> > @@ -66,6 +66,8 @@
>> >  #include "nfs4session.h"
>> >  #include "fscache.h"
>> >
>> > +#include "nfs4trace.h"
>> > +
>> >  #define NFSDBG_FACILITY            NFSDBG_PROC
>> >
>> >  #define NFS4_POLL_RETRY_MIN        (HZ/10)
>> > @@ -4730,6 +4732,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>> >             clp->cl_rpcclient->cl_auth->au_ops->au_name,
>> >             setclientid.sc_name_len, setclientid.sc_name);
>> >     status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_setclientid(clp, status);
>> >     dprintk("NFS reply setclientid: %d\n", status);
>> >     return status;
>> >  }
>> > @@ -4757,6 +4760,7 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
>> >             clp->cl_rpcclient->cl_auth->au_ops->au_name,
>> >             clp->cl_clientid);
>> >     status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_setclientid_confirm(clp, status);
>> >     dprintk("NFS reply setclientid_confirm: %d\n", status);
>> >     return status;
>> >  }
>> > @@ -5887,6 +5891,7 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
>> >     }
>> >
>> >     status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_bind_conn_to_session(clp, status);
>> >     if (status == 0) {
>> >             if (memcmp(res.session->sess_id.data,
>> >                 clp->cl_session->sess_id.data, NFS4_MAX_SESSIONID_LEN)) {
>> > @@ -5972,6 +5977,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>> >     }
>> >
>> >     status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_exchange_id(clp, status);
>> >     if (status == 0)
>> >             status = nfs4_check_cl_exchange_flags(res.flags);
>> >
>> > @@ -6032,6 +6038,7 @@ static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
>> >     int status;
>> >
>> >     status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_destroy_clientid(clp, status);
>> >     if (status)
>> >             dprintk("NFS: Got error %d from the server %s on "
>> >                     "DESTROY_CLIENTID.", status, clp->cl_hostname);
>> > @@ -6295,6 +6302,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
>> >     args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
>> >
>> >     status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_create_session(clp, status);
>> >
>> >     if (!status) {
>> >             /* Verify the session's negotiated channel_attrs values */
>> > @@ -6358,6 +6366,7 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
>> >             return status;
>> >
>> >     status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> > +   trace_nfs4_destroy_session(session->clp, status);
>> >
>> >     if (status)
>> >             dprintk("NFS: Got error %d from the server on DESTROY_SESSION. "
>> > diff --git a/fs/nfs/nfs4trace.c b/fs/nfs/nfs4trace.c
>> > new file mode 100644
>> > index 0000000..3f02183
>> > --- /dev/null
>> > +++ b/fs/nfs/nfs4trace.c
>> > @@ -0,0 +1,10 @@
>> > +/*
>> > + * Copyright (c) 2013 Trond Myklebust <Trond.Myklebust@netapp.com>
>> > + */
>> > +#include <linux/nfs_fs.h>
>> > +#include "nfs4_fs.h"
>> > +#include "internal.h"
>> > +
>> > +#define CREATE_TRACE_POINTS
>> > +#include "nfs4trace.h"
>> > +
>> > diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
>> > new file mode 100644
>> > index 0000000..451954f
>> > --- /dev/null
>> > +++ b/fs/nfs/nfs4trace.h
>> > @@ -0,0 +1,205 @@
>> > +#undef TRACE_SYSTEM
>> > +#define TRACE_SYSTEM nfs4
>> > +
>> > +#if !defined(_TRACE_NFS4_H) || defined(TRACE_HEADER_MULTI_READ)
>> > +#define _TRACE_NFS4_H
>> > +
>> > +#include <linux/tracepoint.h>
>> > +
>> > +#define show_nfsv4_errors(error) __print_symbolic(error,           \
>> > +           { NFS4_OK,                      "OK" },                 \
>> > +           /* Mapped by nfs4_stat_to_errno() */                    \
>> > +           { -EPERM,                       "EPERM" },              \
>> > +           { -ENOENT,                      "ENOENT" },             \
>> > +           { -EIO,                         "EIO" },                \
>> > +           { -ENXIO,                       "ENXIO" },              \
>> > +           { -EACCES,                      "EACCES" },             \
>> > +           { -EEXIST,                      "EEXIST" },             \
>> > +           { -EXDEV,                       "EXDEV" },              \
>> > +           { -ENOTDIR,                     "ENOTDIR" },            \
>> > +           { -EISDIR,                      "EISDIR" },             \
>> > +           { -EFBIG,                       "EFBIG" },              \
>> > +           { -ENOSPC,                      "ENOSPC" },             \
>> > +           { -EROFS,                       "EROFS" },              \
>> > +           { -EMLINK,                      "EMLINK" },             \
>> > +           { -ENAMETOOLONG,                "ENAMETOOLONG" },       \
>> > +           { -ENOTEMPTY,                   "ENOTEMPTY" },          \
>> > +           { -EDQUOT,                      "EDQUOT" },             \
>> > +           { -ESTALE,                      "ESTALE" },             \
>> > +           { -EBADHANDLE,                  "EBADHANDLE" },         \
>> > +           { -EBADCOOKIE,                  "EBADCOOKIE" },         \
>> > +           { -ENOTSUPP,                    "ENOTSUPP" },           \
>> > +           { -ETOOSMALL,                   "ETOOSMALL" },          \
>> > +           { -EREMOTEIO,                   "EREMOTEIO" },          \
>> > +           { -EBADTYPE,                    "EBADTYPE" },           \
>> > +           { -EAGAIN,                      "EAGAIN" },             \
>> > +           { -ELOOP,                       "ELOOP" },              \
>> > +           { -EOPNOTSUPP,                  "EOPNOTSUPP" },         \
>> > +           { -EDEADLK,                     "EDEADLK" },            \
>> > +           /* RPC errors */                                        \
>> > +           { -ENOMEM,                      "ENOMEM" },             \
>> > +           { -EKEYEXPIRED,                 "EKEYEXPIRED" },        \
>> > +           { -ETIMEDOUT,                   "ETIMEDOUT" },          \
>> > +           { -ERESTARTSYS,                 "ERESTARTSYS" },        \
>> > +           { -ECONNREFUSED,                "ECONNREFUSED" },       \
>> > +           { -ECONNRESET,                  "ECONNRESET" },         \
>> > +           { -ENETUNREACH,                 "ENETUNREACH" },        \
>> > +           { -EHOSTUNREACH,                "EHOSTUNREACH" },       \
>> > +           { -EHOSTDOWN,                   "EHOSTDOWN" },          \
>> > +           { -EPIPE,                       "EPIPE" },              \
>> > +           { -EPFNOSUPPORT,                "EPFNOSUPPORT" },       \
>> > +           { -EPROTONOSUPPORT,             "EPROTONOSUPPORT" },    \
>> > +           /* NFSv4 native errors */                               \
>> > +           { -NFS4ERR_ACCESS,              "ACCESS" },             \
>> > +           { -NFS4ERR_ATTRNOTSUPP,         "ATTRNOTSUPP" },        \
>> > +           { -NFS4ERR_ADMIN_REVOKED,       "ADMIN_REVOKED" },      \
>> > +           { -NFS4ERR_BACK_CHAN_BUSY,      "BACK_CHAN_BUSY" },     \
>> > +           { -NFS4ERR_BADCHAR,             "BADCHAR" },            \
>> > +           { -NFS4ERR_BADHANDLE,           "BADHANDLE" },          \
>> > +           { -NFS4ERR_BADIOMODE,           "BADIOMODE" },          \
>> > +           { -NFS4ERR_BADLAYOUT,           "BADLAYOUT" },          \
>> > +           { -NFS4ERR_BADNAME,             "BADNAME" },            \
>> > +           { -NFS4ERR_BADOWNER,            "BADOWNER" },           \
>> > +           { -NFS4ERR_BADSESSION,          "BADSESSION" },         \
>> > +           { -NFS4ERR_BADSLOT,             "BADSLOT" },            \
>> > +           { -NFS4ERR_BADTYPE,             "BADTYPE" },            \
>> > +           { -NFS4ERR_BADXDR,              "BADXDR" },             \
>> > +           { -NFS4ERR_BAD_COOKIE,          "BAD_COOKIE" },         \
>> > +           { -NFS4ERR_BAD_HIGH_SLOT,       "BAD_HIGH_SLOT" },      \
>> > +           { -NFS4ERR_BAD_RANGE,           "BAD_RANGE" },          \
>> > +           { -NFS4ERR_BAD_SEQID,           "BAD_SEQID" },          \
>> > +           { -NFS4ERR_BAD_SESSION_DIGEST,  "BAD_SESSION_DIGEST" }, \
>> > +           { -NFS4ERR_BAD_STATEID,         "BAD_STATEID" },        \
>> > +           { -NFS4ERR_CB_PATH_DOWN,        "CB_PATH_DOWN" },       \
>> > +           { -NFS4ERR_CLID_INUSE,          "CLID_INUSE" },         \
>> > +           { -NFS4ERR_CLIENTID_BUSY,       "CLIENTID_BUSY" },      \
>> > +           { -NFS4ERR_COMPLETE_ALREADY,    "COMPLETE_ALREADY" },   \
>> > +           { -NFS4ERR_CONN_NOT_BOUND_TO_SESSION,                   \
>> > +                                           "CONN_NOT_BOUND_TO_SESSION" }, \
>> > +           { -NFS4ERR_DEADLOCK,            "DEADLOCK" },           \
>> > +           { -NFS4ERR_DEADSESSION,         "DEAD_SESSION" },       \
>> > +           { -NFS4ERR_DELAY,               "DELAY" },              \
>> > +           { -NFS4ERR_DELEG_ALREADY_WANTED,                        \
>> > +                                           "DELEG_ALREADY_WANTED" }, \
>> > +           { -NFS4ERR_DELEG_REVOKED,       "DELEG_REVOKED" },      \
>> > +           { -NFS4ERR_DENIED,              "DENIED" },             \
>> > +           { -NFS4ERR_DIRDELEG_UNAVAIL,    "DIRDELEG_UNAVAIL" },   \
>> > +           { -NFS4ERR_DQUOT,               "DQUOT" },              \
>> > +           { -NFS4ERR_ENCR_ALG_UNSUPP,     "ENCR_ALG_UNSUPP" },    \
>> > +           { -NFS4ERR_EXIST,               "EXIST" },              \
>> > +           { -NFS4ERR_EXPIRED,             "EXPIRED" },            \
>> > +           { -NFS4ERR_FBIG,                "FBIG" },               \
>> > +           { -NFS4ERR_FHEXPIRED,           "FHEXPIRED" },          \
>> > +           { -NFS4ERR_FILE_OPEN,           "FILE_OPEN" },          \
>> > +           { -NFS4ERR_GRACE,               "GRACE" },              \
>> > +           { -NFS4ERR_HASH_ALG_UNSUPP,     "HASH_ALG_UNSUPP" },    \
>> > +           { -NFS4ERR_INVAL,               "INVAL" },              \
>> > +           { -NFS4ERR_IO,                  "IO" },                 \
>> > +           { -NFS4ERR_ISDIR,               "ISDIR" },              \
>> > +           { -NFS4ERR_LAYOUTTRYLATER,      "LAYOUTTRYLATER" },     \
>> > +           { -NFS4ERR_LAYOUTUNAVAILABLE,   "LAYOUTUNAVAILABLE" },  \
>> > +           { -NFS4ERR_LEASE_MOVED,         "LEASE_MOVED" },        \
>> > +           { -NFS4ERR_LOCKED,              "LOCKED" },             \
>> > +           { -NFS4ERR_LOCKS_HELD,          "LOCKS_HELD" },         \
>> > +           { -NFS4ERR_LOCK_RANGE,          "LOCK_RANGE" },         \
>> > +           { -NFS4ERR_MINOR_VERS_MISMATCH, "MINOR_VERS_MISMATCH" }, \
>> > +           { -NFS4ERR_MLINK,               "MLINK" },              \
>> > +           { -NFS4ERR_MOVED,               "MOVED" },              \
>> > +           { -NFS4ERR_NAMETOOLONG,         "NAMETOOLONG" },        \
>> > +           { -NFS4ERR_NOENT,               "NOENT" },              \
>> > +           { -NFS4ERR_NOFILEHANDLE,        "NOFILEHANDLE" },       \
>> > +           { -NFS4ERR_NOMATCHING_LAYOUT,   "NOMATCHING_LAYOUT" },  \
>> > +           { -NFS4ERR_NOSPC,               "NOSPC" },              \
>> > +           { -NFS4ERR_NOTDIR,              "NOTDIR" },             \
>> > +           { -NFS4ERR_NOTEMPTY,            "NOTEMPTY" },           \
>> > +           { -NFS4ERR_NOTSUPP,             "NOTSUPP" },            \
>> > +           { -NFS4ERR_NOT_ONLY_OP,         "NOT_ONLY_OP" },        \
>> > +           { -NFS4ERR_NOT_SAME,            "NOT_SAME" },           \
>> > +           { -NFS4ERR_NO_GRACE,            "NO_GRACE" },           \
>> > +           { -NFS4ERR_NXIO,                "NXIO" },               \
>> > +           { -NFS4ERR_OLD_STATEID,         "OLD_STATEID" },        \
>> > +           { -NFS4ERR_OPENMODE,            "OPENMODE" },           \
>> > +           { -NFS4ERR_OP_ILLEGAL,          "OP_ILLEGAL" },         \
>> > +           { -NFS4ERR_OP_NOT_IN_SESSION,   "OP_NOT_IN_SESSION" },  \
>> > +           { -NFS4ERR_PERM,                "PERM" },               \
>> > +           { -NFS4ERR_PNFS_IO_HOLE,        "PNFS_IO_HOLE" },       \
>> > +           { -NFS4ERR_PNFS_NO_LAYOUT,      "PNFS_NO_LAYOUT" },     \
>> > +           { -NFS4ERR_RECALLCONFLICT,      "RECALLCONFLICT" },     \
>> > +           { -NFS4ERR_RECLAIM_BAD,         "RECLAIM_BAD" },        \
>> > +           { -NFS4ERR_RECLAIM_CONFLICT,    "RECLAIM_CONFLICT" },   \
>> > +           { -NFS4ERR_REJECT_DELEG,        "REJECT_DELEG" },       \
>> > +           { -NFS4ERR_REP_TOO_BIG,         "REP_TOO_BIG" },        \
>> > +           { -NFS4ERR_REP_TOO_BIG_TO_CACHE,                        \
>> > +                                           "REP_TOO_BIG_TO_CACHE" }, \
>> > +           { -NFS4ERR_REQ_TOO_BIG,         "REQ_TOO_BIG" },        \
>> > +           { -NFS4ERR_RESTOREFH,           "RESTOREFH" },          \
>> > +           { -NFS4ERR_RETRY_UNCACHED_REP,  "RETRY_UNCACHED_REP" }, \
>> > +           { -NFS4ERR_RETURNCONFLICT,      "RETURNCONFLICT" },     \
>> > +           { -NFS4ERR_ROFS,                "ROFS" },               \
>> > +           { -NFS4ERR_SAME,                "SAME" },               \
>> > +           { -NFS4ERR_SHARE_DENIED,        "SHARE_DENIED" },       \
>> > +           { -NFS4ERR_SEQUENCE_POS,        "SEQUENCE_POS" },       \
>> > +           { -NFS4ERR_SEQ_FALSE_RETRY,     "SEQ_FALSE_RETRY" },    \
>> > +           { -NFS4ERR_SEQ_MISORDERED,      "SEQ_MISORDERED" },     \
>> > +           { -NFS4ERR_SERVERFAULT,         "SERVERFAULT" },        \
>> > +           { -NFS4ERR_STALE,               "STALE" },              \
>> > +           { -NFS4ERR_STALE_CLIENTID,      "STALE_CLIENTID" },     \
>> > +           { -NFS4ERR_STALE_STATEID,       "STALE_STATEID" },      \
>> > +           { -NFS4ERR_SYMLINK,             "SYMLINK" },            \
>> > +           { -NFS4ERR_TOOSMALL,            "TOOSMALL" },           \
>> > +           { -NFS4ERR_TOO_MANY_OPS,        "TOO_MANY_OPS" },       \
>> > +           { -NFS4ERR_UNKNOWN_LAYOUTTYPE,  "UNKNOWN_LAYOUTTYPE" }, \
>> > +           { -NFS4ERR_UNSAFE_COMPOUND,     "UNSAFE_COMPOUND" },    \
>> > +           { -NFS4ERR_WRONGSEC,            "WRONGSEC" },           \
>> > +           { -NFS4ERR_WRONG_CRED,          "WRONG_CRED" },         \
>> > +           { -NFS4ERR_WRONG_TYPE,          "WRONG_TYPE" },         \
>> > +           { -NFS4ERR_XDEV,                "XDEV" })
>> > +
>> > +DECLARE_EVENT_CLASS(nfs4_clientid_event,
>> > +           TP_PROTO(const struct nfs_client *clp,
>> > +                   int error),
>> > +
>> > +           TP_ARGS(clp, error),
>> > +
>> > +           TP_STRUCT__entry(
>> > +                   __string(dstaddr,
>> > +                           rpc_peeraddr2str(clp->cl_rpcclient,
>> > +                                   RPC_DISPLAY_ADDR))
>> > +                   __field(int, error)
>> > +           ),
>> > +
>> > +           TP_fast_assign(
>> > +                   __entry->error = error;
>> > +                   __assign_str(dstaddr,
>> > +                           rpc_peeraddr2str(clp->cl_rpcclient,
>> > +                                           RPC_DISPLAY_ADDR));
>> > +           ),
>> > +
>> > +           TP_printk("error=%d (%s), dstaddr=%s",
>> > +                   __entry->error,
>> > +                   show_nfsv4_errors(__entry->error),
>> > +                   __get_str(dstaddr)
>> > +           )
>> > +);
>> > +#define DEFINE_NFS4_CLIENTID_EVENT(name)           \
>> > +DEFINE_EVENT(nfs4_clientid_event, name,                    \
>> > +           TP_PROTO(const struct nfs_client *clp,  \
>> > +                   int error),                     \
>> > +           TP_ARGS(clp, error))
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_setclientid);
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_setclientid_confirm);
>> > +#ifdef CONFIG_NFS_V4_1
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_exchange_id);
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_create_session);
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_destroy_session);
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_destroy_clientid);
>> > +DEFINE_NFS4_CLIENTID_EVENT(nfs4_bind_conn_to_session);
>> > +#endif /* CONFIG_NFS_V4_1 */
>> > +
>> > +#endif /* _TRACE_NFS4_H */
>> > +
>> > +#undef TRACE_INCLUDE_PATH
>> > +#define TRACE_INCLUDE_PATH .
>> > +#define TRACE_INCLUDE_FILE nfs4trace
>> > +/* This part must be outside protection */
>> > +#include <trace/define_trace.h>
>> > --
>> > 1.8.3.1
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
