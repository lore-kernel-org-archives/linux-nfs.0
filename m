From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [RFC][PATCH] sunrpc: introduce the simple_rpc_pipefs API
Date: Tue, 11 Nov 2008 11:14:52 -0500 (EST)
Message-ID: <Pine.BSO.4.64.0811111103310.28079@citi.umich.edu>
References: <Pine.BSO.4.64.0811101018450.15587@citi.umich.edu>
 <1226337389.7599.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-936936569-1226420092=:28079"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:26490 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbYKKQOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2008 11:14:53 -0500
In-Reply-To: <1226337389.7599.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-936936569-1226420092=:28079
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 10 Nov 2008, Trond Myklebust wrote:

> On Mon, 2008-11-10 at 10:23 -0500, david m. richter wrote:
> > =09hello,
> >=20
> > =09this patch is part of my pNFS/GFS2 work and i'd neglected at=20
> > first to send it to the correct mailing list.  i'm a little unsure of h=
ow=20
> > to broach it, however, since the subsequent patches that then actually=
=20
> > make use of this aren't germane to the list.
> >=20
> > =09i'd appreciate any and all criticism -- i've already gotten a=20
> > couple good suggestions from someone at EMC who's been trying it out.
> >=20
> > =09thanks for your time,
> >=20
> > =09d
> > =09.
> >=20
> >=20
> >=20
> > The rpc_pipefs upcall/downcall mechanism is a particularly useful means=
 by
> > which to communicate between the kernel and userspace, and its pipe-ori=
ented
> > nature makes it familiar to Unix programmers.
> >=20
> > simple_rpc_pipefs is a small API that simplifies tasks that commonly ar=
ise with
> > rpc_pipefs, like making an upcall and blocking the calling thread until=
 a reply
> > is received, among other things.
> >=20
> > Note: the one portion of the existing rpc_pipe_fs code that has been ch=
anged is
> > that struct rpc_pipe_msg has had a u8 "flags" variable added.  The purp=
ose is to
> > allow callers to indicate when making an upcall that a dynamically allo=
cated
> > upcall message buffer and/or struct rpc_pipe_msg should be automaticall=
y freed
> > in the ->destroy_msg() callback; pipefs_generic_destroy_msg() implement=
s this
> > using the new PIPEFS_AUTOFREE_UPCALL_MSG and PIPEFS_AUTOFREE_RPCMSG fla=
gs,
> > respectively.
> >=20
> > The arguments for not setting those flags in pipefs_hdr_t's "flags" var=
iable is
> > that 1) they would be exposed to userland and 2) are orthogonal to a me=
ssage's
> > content.
> > ---
> >  include/linux/sunrpc/rpc_pipe_fs.h       |    4 +
> >  include/linux/sunrpc/simple_rpc_pipefs.h |   99 +++++++
> >  net/sunrpc/Makefile                      |    2 +-
> >  net/sunrpc/simple_rpc_pipefs.c           |  424 ++++++++++++++++++++++=
++++++++
> >  4 files changed, 528 insertions(+), 1 deletions(-)
> >  create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
> >  create mode 100644 net/sunrpc/simple_rpc_pipefs.c
> >=20
> > diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/=
rpc_pipe_fs.h
> > index 51b977a..3850d69 100644
> > --- a/include/linux/sunrpc/rpc_pipe_fs.h
> > +++ b/include/linux/sunrpc/rpc_pipe_fs.h
> > @@ -9,6 +9,10 @@ struct rpc_pipe_msg {
> >  =09size_t len;
> >  =09size_t copied;
> >  =09int errno;
> > +#define PIPEFS_AUTOFREE_RPCMSG       0x01 /* ->destroy_msg frees rpc_p=
ipe_msg */
> > +#define PIPEFS_AUTOFREE_RPCMSG_DATA  0x02 /* ->destroy_msg frees rpc_p=
ipe_msg->data */
> > +#define PIPEFS_AUTOFREE_UPCALL_MSG   PIPEFS_AUTOFREE_RPCMSG_DATA
> > +=09u8 flags;
> >  };
> > =20
> >  struct rpc_pipe_ops {
> > diff --git a/include/linux/sunrpc/simple_rpc_pipefs.h b/include/linux/s=
unrpc/simple_rpc_pipefs.h
> > new file mode 100644
> > index 0000000..bab94bc
> > --- /dev/null
> > +++ b/include/linux/sunrpc/simple_rpc_pipefs.h
> > @@ -0,0 +1,99 @@
> > +/*
> > + *  linux/fs/gfs2/simple_rpc_pipefs.h
> > + *
> > + *  Copyright (c) 2008 The Regents of the University of Michigan.
> > + *  All rights reserved.
> > + *
> > + *  David M. Richter <richterd@citi.umich.edu>
> > + *
> > + *  Drawing on work done by Andy Adamson <andros@citi.umich.edu> and
> > + *  Marius Eriksen <marius@monkey.org>.  Thanks for the help over the
> > + *  years, guys.
> > + *
> > + *  Redistribution and use in source and binary forms, with or without
> > + *  modification, are permitted provided that the following conditions
> > + *  are met:
> > + *
> > + *  1. Redistributions of source code must retain the above copyright
> > + *     notice, this list of conditions and the following disclaimer.
> > + *  2. Redistributions in binary form must reproduce the above copyrig=
ht
> > + *     notice, this list of conditions and the following disclaimer in=
 the
> > + *     documentation and/or other materials provided with the distribu=
tion.
> > + *  3. Neither the name of the University nor the names of its
> > + *     contributors may be used to endorse or promote products derived
> > + *     from this software without specific prior written permission.
> > + *
> > + *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> > + *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES =
OF
> > + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> > + *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABL=
E
> > + *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> > + *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT =
OF
> > + *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> > + *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> > + *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDI=
NG
> > + *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> > + *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> > + *
> > + *  With thanks to CITI's project sponsor and partner, IBM.
> > + */
> > +
> > +#ifndef _SIMPLE_RPC_PIPEFS_H_
> > +#define _SIMPLE_RPC_PIPEFS_H_
> > +
> > +#include <linux/fs.h>
> > +#include <linux/list.h>
> > +#include <linux/mount.h>
> > +#include <linux/sched.h>
> > +#include <linux/sunrpc/clnt.h>
> > +#include <linux/sunrpc/rpc_pipe_fs.h>
> > +
> > +
> > +#define payload_of(headerp)  ((void *)(headerp + 1))
> > +
> > +/*
> > + * pipefs_hdr_t -- the generic message format for simple_rpc_pipefs.  =
Messages
> > + * may simply be the header itself, although having an optional data p=
ayload
> > + * follow the header allows much more flexibility.
> > + *
> > + * Messages are created using pipefs_alloc_init_msg() and
> > + * pipefs_alloc_init_msg_padded(), both of which accept a pointer to a=
n
> > + * (optional) data payload.
> > + *
> > + * Given a pipefs_hdr_t *msg that has a struct foo payload, the data c=
an be
> > + * accessed using: struct foo *foop =3D payload_of(msg)
> > + */
> > +typedef struct pipefs_hdr {
> > +=09u32 msgid;
> > +=09u8  type;
> > +=09u8  flags;
> > +=09u16 totallen; /* length of entire message, including hdr itself */
> > +=09u32 status;
> > +} pipefs_hdr_t;
> > +
> > +/*
> > + * pipefs_list_t -- a type of list used for tracking callers who've ma=
de an
> > + * upcall and are blocked waiting for a reply.
> > + *
> > + * See pipefs_queue_upcall_waitreply() and pipefs_assign_upcall_reply(=
).
> > + */
> > +typedef struct pipefs_list {
> > +=09struct list_head list;
> > +=09spinlock_t list_lock;
> > +} pipefs_list_t;
>=20
> No thank you! These are structs, and hiding that using a typedef is a
> sure fire way to ensure that someone will one day decide to try to pass
> one by value.

=09ooh, touch=E9!  that's a great point; thx.=20


> Please see the CodingStyle doc on this issue...
>=20
> > +
> > +/* See net/sunrpc/simple_rpc_pipefs.c for more info on using these fun=
ctions. */
> > +extern struct dentry* pipefs_mkpipe(const char *name, struct rpc_pipe_=
ops *ops, int wait_for_open);
> > +extern void pipefs_closepipe(struct dentry *pipe);
> > +extern void pipefs_init_list(pipefs_list_t *list);
> > +extern pipefs_hdr_t* pipefs_alloc_init_msg(u32 msgid, u8 type, u8 flag=
s, void *data, u16 datalen);
> > +extern pipefs_hdr_t* pipefs_alloc_init_msg_padded(u32 msgid, u8 type, =
u8 flags, void *data, u16 datalen, u16 padlen);
> > +extern pipefs_hdr_t* pipefs_queue_upcall_waitreply(struct dentry *pipe=
, pipefs_hdr_t *msg, pipefs_list_t *uplist, u8 upflags, u32 timeout);
> > +extern int pipefs_queue_upcall_noreply(struct dentry *pipe, pipefs_hdr=
_t *msg, u8 upflags);
> > +extern int pipefs_assign_upcall_reply(pipefs_hdr_t *reply, pipefs_list=
_t *uplist);
> > +extern pipefs_hdr_t* pipefs_readmsg(struct file *filp, const char __us=
er *src, size_t len);
> > +extern ssize_t pipefs_generic_upcall(struct file *filp, struct rpc_pip=
e_msg *rpcmsg, char __user *dst, size_t buflen);
> > +extern void pipefs_generic_destroy_msg(struct rpc_pipe_msg *rpcmsg);
> > +
> > +#endif /* _SIMPLE_RPC_PIPEFS_H_ */
> > diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> > index db73fd2..bf44221 100644
> > --- a/net/sunrpc/Makefile
> > +++ b/net/sunrpc/Makefile
> > @@ -12,7 +12,7 @@ sunrpc-y :=3D clnt.o xprt.o socklib.o xprtsock.o sche=
d.o \
> >  =09    svc.o svcsock.o svcauth.o svcauth_unix.o \
> >  =09    rpcb_clnt.o timer.o xdr.o \
> >  =09    sunrpc_syms.o cache.o rpc_pipe.o \
> > -=09    svc_xprt.o
> > +=09    svc_xprt.o simple_rpc_pipefs.o
> >  sunrpc-$(CONFIG_NFS_V4_1) +=3D backchannel_rqst.o bc_svc.o
> >  sunrpc-$(CONFIG_PROC_FS) +=3D stats.o
> >  sunrpc-$(CONFIG_SYSCTL) +=3D sysctl.o
> > diff --git a/net/sunrpc/simple_rpc_pipefs.c b/net/sunrpc/simple_rpc_pip=
efs.c
> > new file mode 100644
> > index 0000000..bd95958
> > --- /dev/null
> > +++ b/net/sunrpc/simple_rpc_pipefs.c
> > @@ -0,0 +1,424 @@
> > +/*
> > + *  net/sunrpc/simple_rpc_pipefs.c
> > + *
> > + *  Copyright (c) 2008 The Regents of the University of Michigan.
> > + *  All rights reserved.
> > + *
> > + *  David M. Richter <richterd@citi.umich.edu>
> > + *
> > + *  Drawing on work done by Andy Adamson <andros@citi.umich.edu> and
> > + *  Marius Eriksen <marius@monkey.org>.  Thanks for the help over the
> > + *  years, guys.
> > + *
> > + *  Redistribution and use in source and binary forms, with or without
> > + *  modification, are permitted provided that the following conditions
> > + *  are met:
> > + *
> > + *  1. Redistributions of source code must retain the above copyright
> > + *     notice, this list of conditions and the following disclaimer.
> > + *  2. Redistributions in binary form must reproduce the above copyrig=
ht
> > + *     notice, this list of conditions and the following disclaimer in=
 the
> > + *     documentation and/or other materials provided with the distribu=
tion.
> > + *  3. Neither the name of the University nor the names of its
> > + *     contributors may be used to endorse or promote products derived
> > + *     from this software without specific prior written permission.
> > + *
> > + *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> > + *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES =
OF
> > + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> > + *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABL=
E
> > + *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> > + *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT =
OF
> > + *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> > + *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> > + *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDI=
NG
> > + *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> > + *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> > + *
> > + *  With thanks to CITI's project sponsor and partner, IBM.
> > + */
> > +
> > +#include <linux/completion.h>
> > +#include <linux/uaccess.h>
> > +#include <linux/module.h>
> > +#include <linux/sunrpc/simple_rpc_pipefs.h>
> > +
> > +
> > +/*
> > + * Make an rpc_pipefs pipe named @name at the root of the mounted rpc_=
pipefs
> > + * filesystem.
> > + *
> > + * If @wait_for_open is non-zero and an upcall is later queued but the=
 userland
> > + * end of the pipe has not yet been opened, the upcall will remain que=
ued until
> > + * the pipe is opened; otherwise, the upcall queueing will return with=
 -EPIPE.
> > + */
> > +struct dentry* pipefs_mkpipe(const char *name, struct rpc_pipe_ops *op=
s,
> > +=09=09=09     int wait_for_open)
> > +{
> > +=09struct dentry *dir, *pipe;
> > +=09struct vfsmount *mnt;
> > +
> > +=09mnt =3D rpc_get_mount();
> > +=09if (IS_ERR(mnt)) {
> > +=09=09pipe =3D ERR_CAST(mnt);
> > +=09=09goto out;
> > +=09}
> > +=09dir =3D mnt->mnt_root;
> > +=09if (!dir) {
> > +=09=09pipe =3D ERR_PTR(-ENOENT);
> > +=09=09goto out;
> > +=09}
> > +=09pipe =3D rpc_mkpipe(dir, name, NULL, ops,
> > +=09=09=09  wait_for_open ? RPC_PIPE_WAIT_FOR_OPEN : 0);
> > +out:
> > +=09return pipe;
> > +}
> > +EXPORT_SYMBOL(pipefs_mkpipe);
> > +
> > +/*
> > + * Shutdown a pipe made by pipefs_mkpipe().
> > + * XXX: do we need to retain an extra reference on the mount?
> > + */
> > +void pipefs_closepipe(struct dentry *pipe)
> > +{
> > +=09rpc_unlink(pipe);
> > +=09rpc_put_mount();
> > +}
> > +EXPORT_SYMBOL(pipefs_closepipe);
> > +
> > +/*
> > + * Initialize a pipefs_list_t -- which are a way to keep track of call=
ers
> > + * who're blocked having made an upcall and are awaiting a reply.
> > + *
> > + * See pipefs_queue_upcall_waitreply() and pipefs_find_upcall_msgid() =
for how
> > + * to use them.
> > + */
> > +inline void pipefs_init_list(pipefs_list_t *list)
> > +{
> > +=09INIT_LIST_HEAD(&list->list);
> > +=09spin_lock_init(&list->list_lock);
> > +}
> > +EXPORT_SYMBOL(pipefs_init_list);
> > +
> > +/*
> > + * Alloc/init a generic pipefs message header and copy into its messag=
e body
> > + * an arbitrary data payload.
> > + *
> > + * pipefs_hdr_t's are meant to serve as generic, general-purpose messa=
ge
> > + * headers for easy rpc_pipefs I/O.  When an upcall is made, the
> > + * pipefs_hdr_t is assigned to a struct rpc_pipe_msg and delivered
> > + * therein.  --And yes, the naming can seem a little confusing at firs=
t:
> > + *
> > + * When one thinks of an upcall "message", in simple_rpc_pipefs that's=
 a
> > + * pipefs_hdr_t (possibly with an attached message body).  A
> > + * struct rpc_pipe_msg is actually only the -vehicle- by which the "re=
al"
> > + * message is delivered and processed.
> > + */
> > +pipefs_hdr_t* pipefs_alloc_init_msg_padded(u32 msgid, u8 type, u8 flag=
s,
> > +=09=09=09=09=09   void *data, u16 datalen, u16 padlen)
> > +{
> > +=09u16 totallen;
> > +=09pipefs_hdr_t *msg =3D NULL;
> > +
> > +=09totallen =3D sizeof(*msg) + datalen + padlen;
> > +=09if (totallen > PAGE_SIZE) {
> > +=09=09msg =3D ERR_PTR(-E2BIG);
> > +=09=09goto out;
> > +=09}
> > +
> > +=09msg =3D kzalloc(totallen, GFP_KERNEL);
> > +=09if (!msg) {
> > +=09=09msg =3D ERR_PTR(-ENOMEM);
> > +=09=09goto out;
> > +=09}
> > +
> > +=09msg->msgid =3D msgid;
> > +=09msg->type =3D type;
> > +=09msg->flags =3D flags;
> > +=09msg->totallen =3D totallen;
> > +=09memcpy(payload_of(msg), data, datalen);
> > +out:
> > +=09return msg;
> > +}
> > +EXPORT_SYMBOL(pipefs_alloc_init_msg_padded);
> > +
> > +/*
> > + * See the description of pipefs_alloc_init_msg_padded().
> > + */
> > +pipefs_hdr_t* pipefs_alloc_init_msg(u32 msgid, u8 type, u8 flags,
> > +=09=09=09=09    void *data, u16 datalen)
> > +{
> > +=09return pipefs_alloc_init_msg_padded(msgid, type, flags, data,
> > +=09=09=09=09=09    datalen, 0);
> > +}
> > +EXPORT_SYMBOL(pipefs_alloc_init_msg);
> > +
> > +
> > +static void pipefs_init_rpcmsg(struct rpc_pipe_msg *rpcmsg, pipefs_hdr=
_t *msg,
> > +=09=09=09       u8 upflags)
> > +{
> > +=09memset(rpcmsg, 0, sizeof(*rpcmsg));
> > +=09rpcmsg->data =3D msg;
> > +=09rpcmsg->len =3D msg->totallen;
> > +=09rpcmsg->flags =3D upflags;
> > +}
> > +
> > +static struct rpc_pipe_msg* pipefs_alloc_init_rpcmsg(pipefs_hdr_t *msg=
,
> > +=09=09=09=09=09=09     u8 upflags)
> > +{
> > +=09struct rpc_pipe_msg *rpcmsg;
> > +
> > +=09rpcmsg =3D kmalloc(sizeof(*rpcmsg), GFP_KERNEL);
> > +=09if (!rpcmsg)
> > +=09=09return ERR_PTR(-ENOMEM);
> > +
> > +=09pipefs_init_rpcmsg(rpcmsg, msg, upflags);
> > +=09return rpcmsg;
> > +}
> > +
> > +
> > +/* represents an upcall that'll block and wait for a reply */
> > +typedef struct pipefs_upcall {
> > +=09u32 msgid;
> > +=09struct rpc_pipe_msg rpcmsg;
> > +=09struct list_head list;
> > +=09wait_queue_head_t waitq;
> > +=09struct pipefs_hdr *reply;
> > +} pipefs_upcall_t;
> > +
> > +
> > +static void pipefs_init_upcall_waitreply(pipefs_upcall_t *upcall,
> > +=09=09=09=09=09 pipefs_hdr_t *msg, u8 upflags)
> > +{
> > +=09upcall->reply =3D NULL;
> > +=09upcall->msgid =3D msg->msgid;
> > +=09INIT_LIST_HEAD(&upcall->list);
> > +=09init_waitqueue_head(&upcall->waitq);
> > +=09pipefs_init_rpcmsg(&upcall->rpcmsg, msg, upflags);
> > +}
> > +
> > +static int __pipefs_queue_upcall_waitreply(struct dentry *pipe,
> > +=09=09=09=09=09   pipefs_upcall_t *upcall,
> > +=09=09=09=09=09   pipefs_list_t *uplist, u32 timeout)
> > +{
> > +=09int err =3D 0;
> > +=09DECLARE_WAITQUEUE(wq, current);
> > +
> > +=09add_wait_queue(&upcall->waitq, &wq);
> > +=09spin_lock(&uplist->list_lock);
> > +=09list_add(&upcall->list, &uplist->list);
> > +=09spin_unlock(&uplist->list_lock);
> > +
> > +=09err =3D rpc_queue_upcall(pipe->d_inode, &upcall->rpcmsg);
> > +=09if (err < 0)
> > +=09=09goto out;
> > +
> > +=09if (timeout) {
> > +=09=09/* retval of 0 means timer expired */
> > +=09=09err =3D schedule_timeout_uninterruptible(timeout);
> > +=09=09if (err =3D=3D 0 && upcall->reply =3D=3D NULL)
> > +=09=09=09err =3D -ETIMEDOUT;
> > +=09} else {
> > +=09=09set_current_state(TASK_UNINTERRUPTIBLE);
> > +=09=09schedule();
> > +=09=09__set_current_state(TASK_RUNNING);
> > +=09}
> > +
> > +=09spin_lock(&uplist->list_lock);
> > +=09list_del_init(&upcall->list);
> > +=09spin_unlock(&uplist->list_lock);
> > +=09remove_wait_queue(&upcall->waitq, &wq);
> > +out:
> > +=09return err;
> > +}
> > +
> > +/*
> > + * Queue a pipefs msg for an upcall to userspace, place the calling th=
read
> > + * on @uplist, and block the thread to wait for a reply.  If @timeout =
is
> > + * nonzero, the thread will be blocked for at most @timeout jiffies.
> > + *
> > + * (To convert time units into jiffies, consider the functions
> > + *  msecs_to_jiffies(), usecs_to_jiffies(), timeval_to_jiffies(), and
> > + *  timespec_to_jiffies().)
> > + *
> > + * Once a reply is received by your downcall handler, call
> > + * pipefs_assign_upcall_reply() with @uplist to find the corresponding=
 upcall,
> > + * assign the reply, and wake the waiting thread.
> > + *
> > + * This function's return value pointer may be an error and should be =
checked
> > + * with IS_ERR() before attempting to access the reply message.
> > + *
> > + * Callers are responsible for freeing @msg, unless pipefs_generic_des=
troy_msg()
> > + * is used as the ->destroy_msg() callback and the PIPEFS_AUTOFREE_UPC=
ALL_MSG
> > + * flag is set in @upflags.  See also rpc_pipe_fs.h.
>=20
> How does the caller know that the message has been freed by
> pipefs_generic_destroy_msg()? There be dragons here!

=09yes, i should spell things out more explicitly here -- it's gotta=20
be incumbent on the caller to know a priori what ->destroy_msg() is going=
=20
to do, at least until a need and a clever suggestion arise.  i didn't want=
=20
to try to add a bunch of apparatus and end up trying to implement a bad=20
version of Obj-C's autorelease pools :)

=09thanks for reading through this, trond.  oh, and i have a wiki=20
entry with example code that i'll probably put on linux-nfs.org once i get=
=20
this patch fixed up; that might help make the case and/or generate=20
criticism.

=09d
=09.
=20
> > + */
> > +pipefs_hdr_t* pipefs_queue_upcall_waitreply(struct dentry *pipe,
> > +=09=09=09=09=09    pipefs_hdr_t *msg,
> > +=09=09=09=09=09    pipefs_list_t *uplist,
> > +=09=09=09=09=09    u8 upflags, u32 timeout)
> > +{
> > +=09int err =3D 0;
> > +=09pipefs_upcall_t upcall;
> > +
> > +=09pipefs_init_upcall_waitreply(&upcall, msg, upflags);
> > +=09err =3D __pipefs_queue_upcall_waitreply(pipe, &upcall, uplist, time=
out);
> > +=09if (err) {
> > +=09=09kfree(upcall.reply);
> > +=09=09upcall.reply =3D ERR_PTR(err);
> > +=09}
> > +
> > +=09return upcall.reply;
> > +}
> > +EXPORT_SYMBOL(pipefs_queue_upcall_waitreply);
> > +
> > +/*
> > + * Queue a pipefs msg for an upcall to userspace and immediately retur=
n (i.e.,
> > + * no reply is expected).
> > + *
> > + * Callers are responsible for freeing @msg, unless pipefs_generic_des=
troy_msg()
> > + * is used as the ->destroy_msg() callback and the PIPEFS_AUTOFREE_UPC=
ALL_MSG
> > + * flag is set in @upflags.  See also rpc_pipe_fs.h.
> > + */
> > +int pipefs_queue_upcall_noreply(struct dentry *pipe, pipefs_hdr_t *msg=
,
> > +=09=09=09=09u8 upflags)
> > +{
> > +=09int err =3D 0;
> > +=09struct rpc_pipe_msg *rpcmsg;
> > +
> > +=09upflags |=3D PIPEFS_AUTOFREE_RPCMSG;
> > +=09rpcmsg =3D pipefs_alloc_init_rpcmsg(msg, upflags);
> > +=09if (IS_ERR(rpcmsg)) {
> > +=09=09err =3D PTR_ERR(rpcmsg);
> > +=09=09goto out;
> > +=09}
> > +=09err =3D rpc_queue_upcall(pipe->d_inode, rpcmsg);
> > +out:
> > +=09return err;
> > +}
> > +EXPORT_SYMBOL(pipefs_queue_upcall_noreply);
> > +
> > +
> > +static pipefs_upcall_t* pipefs_find_upcall_msgid(u32 msgid,
> > +=09=09=09=09=09=09 pipefs_list_t *uplist)
> > +{
> > +=09pipefs_upcall_t *upcall;
> > +
> > +=09spin_lock(&uplist->list_lock);
> > +=09list_for_each_entry(upcall, &uplist->list, list)
> > +=09=09if (upcall->msgid =3D=3D msgid)
> > +=09=09=09goto out;
> > +=09upcall =3D NULL;
> > +out:
> > +=09spin_unlock(&uplist->list_lock);
> > +=09return upcall;
> > +}
> > +
> > +/*
> > + * In your rpc_pipe_ops->downcall() handler, once you've read in a dow=
ncall
> > + * message and have determined that it is a reply to a waiting upcall,
> > + * you can use this function to find the appropriate upcall, assign th=
e result,
> > + * and wake the upcall thread.
> > + *
> > + * The reply message must have the same msgid as the original upcall m=
essage's.
> > + *
> > + * See also pipefs_queue_upcall_waitreply() and pipefs_readmsg().
> > + */
> > +int pipefs_assign_upcall_reply(pipefs_hdr_t *reply, pipefs_list_t *upl=
ist)
> > +{
> > +=09int err =3D 0;
> > +=09pipefs_upcall_t *upcall;
> > +
> > +=09upcall =3D pipefs_find_upcall_msgid(reply->msgid, uplist);
> > +=09if (!upcall) {
> > +=09=09printk(KERN_ERR "%s: ERROR: have reply but no matching upcall "
> > +=09=09=09"for msgid %d\n", __func__, reply->msgid);
> > +=09=09err =3D -ENOENT;
> > +=09=09goto out;
> > +=09}
> > +=09upcall->reply =3D reply;
> > +=09wake_up(&upcall->waitq);
> > +out:
> > +=09return err;
> > +}
> > +EXPORT_SYMBOL(pipefs_assign_upcall_reply);
> > +
> > +/*
> > + * Generic method to read-in and return a newly-allocated message whic=
h begins
> > + * with a pipefs_hdr_t.
> > + */
> > +pipefs_hdr_t* pipefs_readmsg(struct file *filp, const char __user *src=
,
> > +=09=09=09     size_t len)
> > +{
> > +=09int err =3D 0, hdrsize;
> > +=09pipefs_hdr_t *msg =3D NULL;
> > +
> > +=09hdrsize =3D sizeof(*msg);
> > +=09if (len < hdrsize) {
> > +=09=09printk(KERN_ERR "%s: ERROR: header is too short (%d vs %d)\n",
> > +=09=09       __func__, len, hdrsize);
> > +=09=09err =3D -EINVAL;
> > +=09=09goto out;
> > +=09}
> > +
> > +=09msg =3D kzalloc(len, GFP_KERNEL);
> > +=09if (!msg) {
> > +=09=09err =3D -ENOMEM;
> > +=09=09goto out;
> > +=09}
> > +=09if (copy_from_user(msg, src, len))
> > +=09=09err =3D -EFAULT;
> > +out:
> > +=09if (err) {
> > +=09=09if (msg)
> > +=09=09=09kfree(msg);
> > +=09=09msg =3D ERR_PTR(err);
> > +=09}
> > +=09return msg;
> > +}
> > +EXPORT_SYMBOL(pipefs_readmsg);
> > +
> > +/*
> > + * Generic rpc_pipe_ops->upcall() handler implementation.
> > + *
> > + * Don't call this directly: to make an upcall, use
> > + * pipefs_queue_upcall_waitreply() or pipefs_queue_upcall_noreply().
> > + */
> > +ssize_t pipefs_generic_upcall(struct file *filp, struct rpc_pipe_msg *=
rpcmsg,
> > +=09=09=09      char __user *dst, size_t buflen)
> > +{
> > +=09char *data;
> > +=09ssize_t len, left;
> > +
> > +=09data =3D (char *)rpcmsg->data + rpcmsg->copied;
> > +=09len =3D rpcmsg->len - rpcmsg->copied;
> > +=09if (len > buflen)
> > +=09=09len =3D buflen;
> > +
> > +=09left =3D copy_to_user(dst, data, len);
> > +=09if (left < 0) {
> > +=09=09rpcmsg->errno =3D left;
> > +=09=09return left;
> > +=09}
> > +
> > +=09len -=3D left;
> > +=09rpcmsg->copied +=3D len;
> > +=09rpcmsg->errno =3D 0;
> > +=09return len;
> > +}
> > +EXPORT_SYMBOL(pipefs_generic_upcall);
> > +
> > +/*
> > + * Generic rpc_pipe_ops->destroy_msg() handler implementation.
> > + *
> > + * Items are only freed if @rpcmsg->flags has been set appropriately.
> > + * See pipefs_queue_upcall_noreply() and rpc_pipe_fs.h.
> > + */
> > +void pipefs_generic_destroy_msg(struct rpc_pipe_msg *rpcmsg)
> > +{
> > +=09if (rpcmsg->flags & PIPEFS_AUTOFREE_UPCALL_MSG)
> > +=09=09kfree(rpcmsg->data);
> > +=09if (rpcmsg->flags & PIPEFS_AUTOFREE_RPCMSG)
> > +=09=09kfree(rpcmsg);
> > +}
> > +EXPORT_SYMBOL(pipefs_generic_destroy_msg);
> > +
>=20
>=20
--0-936936569-1226420092=:28079--
