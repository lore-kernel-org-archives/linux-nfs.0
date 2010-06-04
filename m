From: sfaibish <sfaibish@emc.com>
Subject: Re: [pnfs][PATCH 1/3] pnfs-blocklayout client: add simple rpc pipefs
Date: Fri, 04 Jun 2010 14:30:00 -0400
Message-ID: <op.vdsgcaquunckof@usensfaibisl2e.eng.emc.com>
References: <op.vdsfisgtunckof@usensfaibisl2e.eng.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Cc: "pnfs@linux-nfs.org" <pnfs@linux-nfs.org>,
	"Robert Gordon" <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:20933 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab0FDSaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jun 2010 14:30:21 -0400
In-Reply-To: <op.vdsfisgtunckof-sXut7+96orlxdPWQvOaHCoI83tS8F2Zb0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 04 Jun 2010 14:12:18 -0400, sfaibish <sfaibish@emc.com> wrote:

>
> This patch build the generic message format for simple_rpc_pipefs.  =20
> Messages
> may simply be the header itself, although having an optional data =20
> payload follow
> the header allows much more flexibility. Additional it creates an =20
> rpc_pipefs pipe
> named @name at the root of the mounted rpc_pipefs filesystem.
>
> If @wait_for_open is non-zero and an upcall is later queued but the =20
> userland
> end of the pipe has not yet been opened, the upcall will remain queue=
d =20
> until
> the pipe is opened; otherwise, the upcall queueing will return with =20
> -EPIPE.
>
> Alloc/init a generic pipefs message header and copy into its message =
body
> an arbitrary data payload.
> The implementation serve as generic, general-purpose message headers =
for =20
> easy
> rpc_pipefs I/O.  When an upcall is made, the pipefs_hdr_t is assigned=
 to =20
> a
> struct rpc_pipe_msg and delivered therein.
>
> When one thinks of an upcall "message", in simple_rpc_pipefs that's a=
 =20
> pipefs_hdr_t
> (possibly with an attached message body).  A struct rpc_pipe_msg is =20
> actually only
> the -vehicle- by which the "real" message is delivered and processed.
>
> In order to queue a pipefs msg for an upcall to userspace, the code =20
> places the calling
> thread on @uplist, and block the thread to wait for a reply.  If =20
> @timeout is nonzero,
> the thread will be blocked for at most @timeout jiffies. Once a reply=
 is =20
> received by
> your downcall handler, call pipefs_assign_upcall_reply() with @uplist=
 to =20
> find the
> corresponding upcall, assign the reply, and wake the waiting thread.
> At the end of the creation of the "message" the return value pointer =
may =20
> be an error
> that will be checked with IS_ERR() before attempting to access the re=
ply =20
> message.
> Callers are responsible for freeing @msg, unless =20
> pipefs_generic_destroy_msg()
> is used as the ->destroy_msg() callback and the =20
> PIPEFS_AUTOFREE_UPCALL_MSG
> flag is set in @upflags.
>
> Signed-off-by: Sorin Faibish <sfaibish-Wuw85uim5zDR7s880joybQ@public.gmane.org>
> ---
>   include/linux/sunrpc/rpc_pipe_fs.h       |    4 +
>   include/linux/sunrpc/simple_rpc_pipefs.h |  112 ++++++++
>   net/sunrpc/Makefile                      |    2 +-
>   net/sunrpc/simple_rpc_pipefs.c           |  423 =20
> ++++++++++++++++++++++++++++++
>   4 files changed, 540 insertions(+), 1 deletions(-)
>   create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
>   create mode 100644 net/sunrpc/simple_rpc_pipefs.c
>
> diff --git a/include/linux/sunrpc/rpc_pipe_fs.h =20
> b/include/linux/sunrpc/rpc_pipe_fs.h
> index 6f942c9..2177d50 100644
> --- a/include/linux/sunrpc/rpc_pipe_fs.h
> +++ b/include/linux/sunrpc/rpc_pipe_fs.h
> @@ -12,6 +12,10 @@ struct rpc_pipe_msg {
>   	size_t len;
>   	size_t copied;
>   	int errno;
> +#define PIPEFS_AUTOFREE_RPCMSG       0x01 /* frees rpc_pipe_msg */
> +#define PIPEFS_AUTOFREE_RPCMSG_DATA  0x02 /* frees rpc_pipe_msg->dat=
a */
> +#define PIPEFS_AUTOFREE_UPCALL_MSG   PIPEFS_AUTOFREE_RPCMSG_DATA
> +	u8 flags;
>   };
>
>   struct rpc_pipe_ops {
> diff --git a/include/linux/sunrpc/simple_rpc_pipefs.h =20
> b/include/linux/sunrpc/simple_rpc_pipefs.h
> new file mode 100644
> index 0000000..b51ef31
> --- /dev/null
> +++ b/include/linux/sunrpc/simple_rpc_pipefs.h
> @@ -0,0 +1,112 @@
> +/*
> + *  linux/fs/gfs2/simple_rpc_pipefs.h
Should be include/linux/sunrpc/simple_rpc_pipefs.h

> + *
> + *  Copyright (c) 2008 The Regents of the University of Michigan.
> + *  All rights reserved.
> + *
> + *  David M. Richter <richterd@citi.umich.edu>
> + *
> + *  Drawing on work done by Andy Adamson <andros@citi.umich.edu> and
> + *  Marius Eriksen <marius@monkey.org>.  Thanks for the help over th=
e
> + *  years, guys.
> + *
> + *  Redistribution and use in source and binary forms, with or witho=
ut
> + *  modification, are permitted provided that the following conditio=
ns
> + *  are met:
> + *
> + *  1. Redistributions of source code must retain the above copyrigh=
t
> + *     notice, this list of conditions and the following disclaimer.
> + *  2. Redistributions in binary form must reproduce the above copyr=
ight
> + *     notice, this list of conditions and the following disclaimer =
in =20
> the
> + *     documentation and/or other materials provided with the =20
> distribution.
> + *  3. Neither the name of the University nor the names of its
> + *     contributors may be used to endorse or promote products deriv=
ed
> + *     from this software without specific prior written permission.
> + *
> + *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> + *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIE=
S OF
> + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> + *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIA=
BLE
> + *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> + *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMEN=
T OF
> + *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> + *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> + *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLU=
DING
> + *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF TH=
IS
> + *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + *
> + *  With thanks to CITI's project sponsor and partner, IBM.
> + */
> +
> +#ifndef _SIMPLE_RPC_PIPEFS_H_
> +#define _SIMPLE_RPC_PIPEFS_H_
> +
> +#include <linux/fs.h>
> +#include <linux/list.h>
> +#include <linux/mount.h>
> +#include <linux/sched.h>
> +#include <linux/sunrpc/clnt.h>
> +#include <linux/sunrpc/rpc_pipe_fs.h>
> +
> +
> +#define payload_of(headerp)  ((void *)(headerp + 1))
> +
> +/*
> + * pipefs_hdr_t -- the generic message format for simple_rpc_pipefs.=
  =20
> Messages
> + * may simply be the header itself, although having an optional data=
 =20
> payload
> + * follow the header allows much more flexibility.
> + *
> + * Messages are created using pipefs_alloc_init_msg() and
> + * pipefs_alloc_init_msg_padded(), both of which accept a pointer to=
 an
> + * (optional) data payload.
> + *
> + * Given a pipefs_hdr_t *msg that has a struct foo payload, the data=
 =20
> can be
> + * accessed using: struct foo *foop =3D payload_of(msg)
> + */
> +typedef struct pipefs_hdr {
> +	u32 msgid;
> +	u8  type;
> +	u8  flags;
> +	u16 totallen; /* length of entire message, including hdr itself */
> +	u32 status;
> +} pipefs_hdr_t;
> +
> +/*
> + * pipefs_list_t -- a type of list used for tracking callers who've =
=20
> made an
> + * upcall and are blocked waiting for a reply.
> + *
> + * See pipefs_queue_upcall_waitreply() and pipefs_assign_upcall_repl=
y().
> + */
> +typedef struct pipefs_list {
> +	struct list_head list;
> +	spinlock_t list_lock;
> +} pipefs_list_t;
> +
> +
> +/* See net/sunrpc/simple_rpc_pipefs.c for more info on using these =20
> functions. */
> +extern struct dentry *pipefs_mkpipe(const char *name,
> +				    struct rpc_pipe_ops *ops,
> +				    int wait_for_open);
> +extern void pipefs_closepipe(struct dentry *pipe);
> +extern void pipefs_init_list(pipefs_list_t *list);
> +extern pipefs_hdr_t *pipefs_alloc_init_msg(u32 msgid, u8 type, u8 fl=
ags,
> +					   void *data, u16 datalen);
> +extern pipefs_hdr_t *pipefs_alloc_init_msg_padded(u32 msgid, u8 type=
,
> +						  u8 flags, void *data,
> +						  u16 datalen, u16 padlen);
> +extern pipefs_hdr_t *pipefs_queue_upcall_waitreply(struct dentry *pi=
pe,
> +						   pipefs_hdr_t *msg,
> +						   pipefs_list_t *uplist,
> +						   u8 upflags, u32 timeout);
> +extern int pipefs_queue_upcall_noreply(struct dentry *pipe, =20
> pipefs_hdr_t *msg,
> +				       u8 upflags);
> +extern int pipefs_assign_upcall_reply(pipefs_hdr_t *reply,
> +				      pipefs_list_t *uplist);
> +extern pipefs_hdr_t *pipefs_readmsg(struct file *filp, const char =20
> __user *src,
> +				    size_t len);
> +extern ssize_t pipefs_generic_upcall(struct file *filp,
> +				     struct rpc_pipe_msg *rpcmsg,
> +				     char __user *dst, size_t buflen);
> +extern void pipefs_generic_destroy_msg(struct rpc_pipe_msg *rpcmsg);
> +
> +#endif /* _SIMPLE_RPC_PIPEFS_H_ */
> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> index 9d2fca5..e102040 100644
> --- a/net/sunrpc/Makefile
> +++ b/net/sunrpc/Makefile
> @@ -12,7 +12,7 @@ sunrpc-y :=3D clnt.o xprt.o socklib.o xprtsock.o sc=
hed.o =20
> \
>   	    svc.o svcsock.o svcauth.o svcauth_unix.o \
>   	    addr.o rpcb_clnt.o timer.o xdr.o \
>   	    sunrpc_syms.o cache.o rpc_pipe.o \
> -	    svc_xprt.o
> +	    svc_xprt.o simple_rpc_pipefs.o
>   sunrpc-$(CONFIG_NFS_V4_1) +=3D backchannel_rqst.o bc_svc.o
>   sunrpc-$(CONFIG_PROC_FS) +=3D stats.o
>   sunrpc-$(CONFIG_SYSCTL) +=3D sysctl.o
> diff --git a/net/sunrpc/simple_rpc_pipefs.c =20
> b/net/sunrpc/simple_rpc_pipefs.c
> new file mode 100644
> index 0000000..13cf1a2
> --- /dev/null
> +++ b/net/sunrpc/simple_rpc_pipefs.c
> @@ -0,0 +1,423 @@
> +/*
> + *  net/sunrpc/simple_rpc_pipefs.c
> + *
> + *  Copyright (c) 2008 The Regents of the University of Michigan.
> + *  All rights reserved.
> + *
> + *  David M. Richter <richterd@citi.umich.edu>
> + *
> + *  Drawing on work done by Andy Adamson <andros@citi.umich.edu> and
> + *  Marius Eriksen <marius@monkey.org>.  Thanks for the help over th=
e
> + *  years, guys.
> + *
> + *  Redistribution and use in source and binary forms, with or witho=
ut
> + *  modification, are permitted provided that the following conditio=
ns
> + *  are met:
> + *
> + *  1. Redistributions of source code must retain the above copyrigh=
t
> + *     notice, this list of conditions and the following disclaimer.
> + *  2. Redistributions in binary form must reproduce the above copyr=
ight
> + *     notice, this list of conditions and the following disclaimer =
in =20
> the
> + *     documentation and/or other materials provided with the =20
> distribution.
> + *  3. Neither the name of the University nor the names of its
> + *     contributors may be used to endorse or promote products deriv=
ed
> + *     from this software without specific prior written permission.
> + *
> + *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> + *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIE=
S OF
> + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> + *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIA=
BLE
> + *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> + *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMEN=
T OF
> + *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> + *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> + *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLU=
DING
> + *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF TH=
IS
> + *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + *
> + *  With thanks to CITI's project sponsor and partner, IBM.
> + */
> +
> +#include <linux/completion.h>
> +#include <linux/uaccess.h>
> +#include <linux/module.h>
> +#include <linux/sunrpc/simple_rpc_pipefs.h>
> +
> +
> +/*
> + * Make an rpc_pipefs pipe named @name at the root of the mounted =20
> rpc_pipefs
> + * filesystem.
> + *
> + * If @wait_for_open is non-zero and an upcall is later queued but t=
he =20
> userland
> + * end of the pipe has not yet been opened, the upcall will remain =20
> queued until
> + * the pipe is opened; otherwise, the upcall queueing will return wi=
th =20
> -EPIPE.
> + */
> +struct dentry* pipefs_mkpipe(const char *name, struct rpc_pipe_ops *=
ops,
> +			     int wait_for_open)
> +{
> +	struct dentry *dir, *pipe;
> +	struct vfsmount *mnt;
> +
> +	mnt =3D rpc_get_mount();
> +	if (IS_ERR(mnt)) {
> +		pipe =3D ERR_CAST(mnt);
> +		goto out;
> +	}
> +	dir =3D mnt->mnt_root;
> +	if (!dir) {
> +		pipe =3D ERR_PTR(-ENOENT);
> +		goto out;
> +	}
> +	pipe =3D rpc_mkpipe(dir, name, NULL, ops,
> +			  wait_for_open ? RPC_PIPE_WAIT_FOR_OPEN : 0);
> +out:
> +	return pipe;
> +}
> +EXPORT_SYMBOL(pipefs_mkpipe);
> +
> +/*
> + * Shutdown a pipe made by pipefs_mkpipe().
> + * XXX: do we need to retain an extra reference on the mount?
> + */
> +void pipefs_closepipe(struct dentry *pipe)
> +{
> +	rpc_unlink(pipe);
> +	rpc_put_mount();
> +}
> +EXPORT_SYMBOL(pipefs_closepipe);
> +
> +/*
> + * Initialize a pipefs_list_t -- which are a way to keep track of =20
> callers
> + * who're blocked having made an upcall and are awaiting a reply.
> + *
> + * See pipefs_queue_upcall_waitreply() and pipefs_find_upcall_msgid(=
) =20
> for how
> + * to use them.
> + */
> +inline void pipefs_init_list(pipefs_list_t *list)
> +{
> +	INIT_LIST_HEAD(&list->list);
> +	spin_lock_init(&list->list_lock);
> +}
> +EXPORT_SYMBOL(pipefs_init_list);
> +
> +/*
> + * Alloc/init a generic pipefs message header and copy into its mess=
age =20
> body
> + * an arbitrary data payload.
> + *
> + * pipefs_hdr_t's are meant to serve as generic, general-purpose mes=
sage
> + * headers for easy rpc_pipefs I/O.  When an upcall is made, the
> + * pipefs_hdr_t is assigned to a struct rpc_pipe_msg and delivered
> + * therein.  --And yes, the naming can seem a little confusing at fi=
rst:
> + *
> + * When one thinks of an upcall "message", in simple_rpc_pipefs that=
's a
> + * pipefs_hdr_t (possibly with an attached message body).  A
> + * struct rpc_pipe_msg is actually only the -vehicle- by which the =20
> "real"
> + * message is delivered and processed.
> + */
> +pipefs_hdr_t* pipefs_alloc_init_msg_padded(u32 msgid, u8 type, u8 fl=
ags,
> +					   void *data, u16 datalen, u16 padlen)
> +{
> +	u16 totallen;
> +	pipefs_hdr_t *msg =3D NULL;
> +
> +	totallen =3D sizeof(*msg) + datalen + padlen;
> +	if (totallen > PAGE_SIZE) {
> +		msg =3D ERR_PTR(-E2BIG);
> +		goto out;
> +	}
> +
> +	msg =3D kzalloc(totallen, GFP_KERNEL);
> +	if (!msg) {
> +		msg =3D ERR_PTR(-ENOMEM);
> +		goto out;
> +	}
> +
> +	msg->msgid =3D msgid;
> +	msg->type =3D type;
> +	msg->flags =3D flags;
> +	msg->totallen =3D totallen;
> +	memcpy(payload_of(msg), data, datalen);
> +out:
> +	return msg;
> +}
> +EXPORT_SYMBOL(pipefs_alloc_init_msg_padded);
> +
> +/*
> + * See the description of pipefs_alloc_init_msg_padded().
> + */
> +pipefs_hdr_t* pipefs_alloc_init_msg(u32 msgid, u8 type, u8 flags,
> +				    void *data, u16 datalen)
> +{
> +	return pipefs_alloc_init_msg_padded(msgid, type, flags, data,
> +					    datalen, 0);
> +}
> +EXPORT_SYMBOL(pipefs_alloc_init_msg);
> +
> +
> +static void pipefs_init_rpcmsg(struct rpc_pipe_msg *rpcmsg, =20
> pipefs_hdr_t *msg,
> +			       u8 upflags)
> +{
> +	memset(rpcmsg, 0, sizeof(*rpcmsg));
> +	rpcmsg->data =3D msg;
> +	rpcmsg->len =3D msg->totallen;
> +	rpcmsg->flags =3D upflags;
> +}
> +
> +static struct rpc_pipe_msg* pipefs_alloc_init_rpcmsg(pipefs_hdr_t *m=
sg,
> +						     u8 upflags)
> +{
> +	struct rpc_pipe_msg *rpcmsg;
> +
> +	rpcmsg =3D kmalloc(sizeof(*rpcmsg), GFP_KERNEL);
> +	if (!rpcmsg)
> +		return ERR_PTR(-ENOMEM);
> +
> +	pipefs_init_rpcmsg(rpcmsg, msg, upflags);
> +	return rpcmsg;
> +}
> +
> +
> +/* represents an upcall that'll block and wait for a reply */
> +typedef struct pipefs_upcall {
> +	u32 msgid;
> +	struct rpc_pipe_msg rpcmsg;
> +	struct list_head list;
> +	wait_queue_head_t waitq;
> +	struct pipefs_hdr *reply;
> +} pipefs_upcall_t;
> +
> +
> +static void pipefs_init_upcall_waitreply(pipefs_upcall_t *upcall,
> +					 pipefs_hdr_t *msg, u8 upflags)
> +{
> +	upcall->reply =3D NULL;
> +	upcall->msgid =3D msg->msgid;
> +	INIT_LIST_HEAD(&upcall->list);
> +	init_waitqueue_head(&upcall->waitq);
> +	pipefs_init_rpcmsg(&upcall->rpcmsg, msg, upflags);
> +}
> +
> +static int __pipefs_queue_upcall_waitreply(struct dentry *pipe,
> +					   pipefs_upcall_t *upcall,
> +					   pipefs_list_t *uplist, u32 timeout)
> +{
> +	int err =3D 0;
> +	DECLARE_WAITQUEUE(wq, current);
> +
> +	add_wait_queue(&upcall->waitq, &wq);
> +	spin_lock(&uplist->list_lock);
> +	list_add(&upcall->list, &uplist->list);
> +	spin_unlock(&uplist->list_lock);
> +
> +	err =3D rpc_queue_upcall(pipe->d_inode, &upcall->rpcmsg);
> +	if (err < 0)
> +		goto out;
> +
> +	if (timeout) {
> +		/* retval of 0 means timer expired */
> +		err =3D schedule_timeout_uninterruptible(timeout);
> +		if (err =3D=3D 0 && upcall->reply =3D=3D NULL)
> +			err =3D -ETIMEDOUT;
> +	} else {
> +		set_current_state(TASK_UNINTERRUPTIBLE);
> +		schedule();
> +		__set_current_state(TASK_RUNNING);
> +	}
> +
> +out:
> +	spin_lock(&uplist->list_lock);
> +	list_del_init(&upcall->list);
> +	spin_unlock(&uplist->list_lock);
> +	remove_wait_queue(&upcall->waitq, &wq);
> +	return err;
> +}
> +
> +/*
> + * Queue a pipefs msg for an upcall to userspace, place the calling =
=20
> thread
> + * on @uplist, and block the thread to wait for a reply.  If @timeou=
t is
> + * nonzero, the thread will be blocked for at most @timeout jiffies.
> + *
> + * (To convert time units into jiffies, consider the functions
> + *  msecs_to_jiffies(), usecs_to_jiffies(), timeval_to_jiffies(), an=
d
> + *  timespec_to_jiffies().)
> + *
> + * Once a reply is received by your downcall handler, call
> + * pipefs_assign_upcall_reply() with @uplist to find the correspondi=
ng =20
> upcall,
> + * assign the reply, and wake the waiting thread.
> + *
> + * This function's return value pointer may be an error and should b=
e =20
> checked
> + * with IS_ERR() before attempting to access the reply message.
> + *
> + * Callers are responsible for freeing @msg, unless =20
> pipefs_generic_destroy_msg()
> + * is used as the ->destroy_msg() callback and the =20
> PIPEFS_AUTOFREE_UPCALL_MSG
> + * flag is set in @upflags.  See also rpc_pipe_fs.h.
> + */
> +pipefs_hdr_t *pipefs_queue_upcall_waitreply(struct dentry *pipe,
> +					    pipefs_hdr_t *msg,
> +					    pipefs_list_t *uplist,
> +					    u8 upflags, u32 timeout)
> +{
> +	int err =3D 0;
> +	pipefs_upcall_t upcall;
> +
> +	pipefs_init_upcall_waitreply(&upcall, msg, upflags);
> +	err =3D __pipefs_queue_upcall_waitreply(pipe, &upcall, uplist, time=
out);
> +	if (err < 0) {
> +		kfree(upcall.reply);
> +		upcall.reply =3D ERR_PTR(err);
> +	}
> +
> +	return upcall.reply;
> +}
> +EXPORT_SYMBOL(pipefs_queue_upcall_waitreply);
> +
> +/*
> + * Queue a pipefs msg for an upcall to userspace and immediately ret=
urn =20
> (i.e.,
> + * no reply is expected).
> + *
> + * Callers are responsible for freeing @msg, unless =20
> pipefs_generic_destroy_msg()
> + * is used as the ->destroy_msg() callback and the =20
> PIPEFS_AUTOFREE_UPCALL_MSG
> + * flag is set in @upflags.  See also rpc_pipe_fs.h.
> + */
> +int pipefs_queue_upcall_noreply(struct dentry *pipe, pipefs_hdr_t *m=
sg,
> +				u8 upflags)
> +{
> +	int err =3D 0;
> +	struct rpc_pipe_msg *rpcmsg;
> +
> +	upflags |=3D PIPEFS_AUTOFREE_RPCMSG;
> +	rpcmsg =3D pipefs_alloc_init_rpcmsg(msg, upflags);
> +	if (IS_ERR(rpcmsg)) {
> +		err =3D PTR_ERR(rpcmsg);
> +		goto out;
> +	}
> +	err =3D rpc_queue_upcall(pipe->d_inode, rpcmsg);
> +out:
> +	return err;
> +}
> +EXPORT_SYMBOL(pipefs_queue_upcall_noreply);
> +
> +
> +static pipefs_upcall_t *pipefs_find_upcall_msgid(u32 msgid,
> +						 pipefs_list_t *uplist)
> +{
> +	pipefs_upcall_t *upcall;
> +
> +	spin_lock(&uplist->list_lock);
> +	list_for_each_entry(upcall, &uplist->list, list)
> +		if (upcall->msgid =3D=3D msgid)
> +			goto out;
> +	upcall =3D NULL;
> +out:
> +	spin_unlock(&uplist->list_lock);
> +	return upcall;
> +}
> +
> +/*
> + * In your rpc_pipe_ops->downcall() handler, once you've read in a =20
> downcall
> + * message and have determined that it is a reply to a waiting upcal=
l,
> + * you can use this function to find the appropriate upcall, assign =
the =20
> result,
> + * and wake the upcall thread.
> + *
> + * The reply message must have the same msgid as the original upcall=
 =20
> message's.
> + *
> + * See also pipefs_queue_upcall_waitreply() and pipefs_readmsg().
> + */
> +int pipefs_assign_upcall_reply(pipefs_hdr_t *reply, pipefs_list_t =20
> *uplist)
> +{
> +	int err =3D 0;
> +	pipefs_upcall_t *upcall;
> +
> +	upcall =3D pipefs_find_upcall_msgid(reply->msgid, uplist);
> +	if (!upcall) {
> +		printk(KERN_ERR "%s: ERROR: have reply but no matching upcall "
> +			"for msgid %d\n", __func__, reply->msgid);
> +		err =3D -ENOENT;
> +		goto out;
> +	}
> +	upcall->reply =3D reply;
> +	wake_up(&upcall->waitq);
> +out:
> +	return err;
> +}
> +EXPORT_SYMBOL(pipefs_assign_upcall_reply);
> +
> +/*
> + * Generic method to read-in and return a newly-allocated message wh=
ich =20
> begins
> + * with a pipefs_hdr_t.
> + */
> +pipefs_hdr_t *pipefs_readmsg(struct file *filp, const char __user *s=
rc,
> +			     size_t len)
> +{
> +	int err =3D 0, hdrsize;
> +	pipefs_hdr_t *msg =3D NULL;
> +
> +	hdrsize =3D sizeof(*msg);
> +	if (len < hdrsize) {
> +		printk(KERN_ERR "%s: ERROR: header is too short (%d vs %d)\n",
> +		       __func__, len, hdrsize);
> +		err =3D -EINVAL;
> +		goto out;
> +	}
> +
> +	msg =3D kzalloc(len, GFP_KERNEL);
> +	if (!msg) {
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> +	if (copy_from_user(msg, src, len))
> +		err =3D -EFAULT;
> +out:
> +	if (err) {
> +		kfree(msg);
> +		msg =3D ERR_PTR(err);
> +	}
> +	return msg;
> +}
> +EXPORT_SYMBOL(pipefs_readmsg);
> +
> +/*
> + * Generic rpc_pipe_ops->upcall() handler implementation.
> + *
> + * Don't call this directly: to make an upcall, use
> + * pipefs_queue_upcall_waitreply() or pipefs_queue_upcall_noreply().
> + */
> +ssize_t pipefs_generic_upcall(struct file *filp, struct rpc_pipe_msg=
 =20
> *rpcmsg,
> +			      char __user *dst, size_t buflen)
> +{
> +	char *data;
> +	ssize_t len, left;
> +
> +	data =3D (char *)rpcmsg->data + rpcmsg->copied;
> +	len =3D rpcmsg->len - rpcmsg->copied;
> +	if (len > buflen)
> +		len =3D buflen;
> +
> +	left =3D copy_to_user(dst, data, len);
> +	if (left < 0) {
> +		rpcmsg->errno =3D left;
> +		return left;
> +	}
> +
> +	len -=3D left;
> +	rpcmsg->copied +=3D len;
> +	rpcmsg->errno =3D 0;
> +	return len;
> +}
> +EXPORT_SYMBOL(pipefs_generic_upcall);
> +
> +/*
> + * Generic rpc_pipe_ops->destroy_msg() handler implementation.
> + *
> + * Items are only freed if @rpcmsg->flags has been set appropriately=
=2E
> + * See pipefs_queue_upcall_noreply() and rpc_pipe_fs.h.
> + */
> +void pipefs_generic_destroy_msg(struct rpc_pipe_msg *rpcmsg)
> +{
> +	if (rpcmsg->flags & PIPEFS_AUTOFREE_UPCALL_MSG)
> +		kfree(rpcmsg->data);
> +	if (rpcmsg->flags & PIPEFS_AUTOFREE_RPCMSG)
> +		kfree(rpcmsg);
> +}
> +EXPORT_SYMBOL(pipefs_generic_destroy_msg);
> +



--=20
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
