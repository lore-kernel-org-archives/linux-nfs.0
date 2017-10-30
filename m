Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:52453 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdJ3D5J (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Oct 2017 23:57:09 -0400
Received: by mail-wm0-f65.google.com with SMTP id t139so13605984wmt.1
        for <linux-nfs@vger.kernel.org>; Sun, 29 Oct 2017 20:57:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <63736984-243A-4F17-A146-57A0CA8E5061@oracle.com>
References: <20171027164014.10826.10151.stgit@manet.1015granger.net>
 <20171027164402.10826.42984.stgit@manet.1015granger.net> <CANjDDBjUzfCJjaGb9aq9YC7ZKrvYoVuXThV3RV1fu-fo=Sjfew@mail.gmail.com>
 <63736984-243A-4F17-A146-57A0CA8E5061@oracle.com>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Mon, 30 Oct 2017 09:26:27 +0530
Message-ID: <CANjDDBggWLd7VobCoRBozVhVVbEtR6D0Ne-qOBvs+2qFQmEmNA@mail.gmail.com>
Subject: Re: [PATCH 2/4] rpcrdma: Remove C structure definitions of XDR data items
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Okay looks good to me.

-Regards
Devesh

On Sun, Oct 29, 2017 at 10:58 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Oct 28, 2017, at 3:38 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
>>
>> Hi Chuck,
>
> Hi Devesh, thanks for the review!
>
>
>> Could add a pointer to the patch which replaced things with the new
>> data-structure in the commit message
>
> How about this:
>
> "Clean up: C-structure style XDR encoding and decoding logic has
> been replaced over the past several merge windows on both the
> client and server. These data structures are no longer used."
>
>
>> On Fri, Oct 27, 2017 at 10:14 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> Clean up: XDR structures have been replaced in all client and server
>>> transport code.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> include/linux/sunrpc/rpc_rdma.h |   59 ---------------------------------------
>>> net/sunrpc/xprtrdma/rpc_rdma.c  |    6 ++--
>>> net/sunrpc/xprtrdma/xprt_rdma.h |    6 ----
>>> 3 files changed, 3 insertions(+), 68 deletions(-)
>>>
>>> diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
>>> index b7e85b3..840afac 100644
>>> --- a/include/linux/sunrpc/rpc_rdma.h
>>> +++ b/include/linux/sunrpc/rpc_rdma.h
>>> @@ -50,65 +50,6 @@ enum {
>>>        RPCRDMA_V1_DEF_INLINE_SIZE      = 1024,
>>> };
>>>
>>> -struct rpcrdma_segment {
>>> -       __be32 rs_handle;       /* Registered memory handle */
>>> -       __be32 rs_length;       /* Length of the chunk in bytes */
>>> -       __be64 rs_offset;       /* Chunk virtual address or offset */
>>> -};
>>> -
>>> -/*
>>> - * read chunk(s), encoded as a linked list.
>>> - */
>>> -struct rpcrdma_read_chunk {
>>> -       __be32 rc_discrim;      /* 1 indicates presence */
>>> -       __be32 rc_position;     /* Position in XDR stream */
>>> -       struct rpcrdma_segment rc_target;
>>> -};
>>> -
>>> -/*
>>> - * write chunk, and reply chunk.
>>> - */
>>> -struct rpcrdma_write_chunk {
>>> -       struct rpcrdma_segment wc_target;
>>> -};
>>> -
>>> -/*
>>> - * write chunk(s), encoded as a counted array.
>>> - */
>>> -struct rpcrdma_write_array {
>>> -       __be32 wc_discrim;      /* 1 indicates presence */
>>> -       __be32 wc_nchunks;      /* Array count */
>>> -       struct rpcrdma_write_chunk wc_array[0];
>>> -};
>>> -
>>> -struct rpcrdma_msg {
>>> -       __be32 rm_xid;  /* Mirrors the RPC header xid */
>>> -       __be32 rm_vers; /* Version of this protocol */
>>> -       __be32 rm_credit;       /* Buffers requested/granted */
>>> -       __be32 rm_type; /* Type of message (enum rpcrdma_proc) */
>>> -       union {
>>> -
>>> -               struct {                        /* no chunks */
>>> -                       __be32 rm_empty[3];     /* 3 empty chunk lists */
>>> -               } rm_nochunks;
>>> -
>>> -               struct {                        /* no chunks and padded */
>>> -                       __be32 rm_align;        /* Padding alignment */
>>> -                       __be32 rm_thresh;       /* Padding threshold */
>>> -                       __be32 rm_pempty[3];    /* 3 empty chunk lists */
>>> -               } rm_padded;
>>> -
>>> -               struct {
>>> -                       __be32 rm_err;
>>> -                       __be32 rm_vers_low;
>>> -                       __be32 rm_vers_high;
>>> -               } rm_error;
>>> -
>>> -               __be32 rm_chunks[0];    /* read, write and reply chunks */
>>> -
>>> -       } rm_body;
>>> -};
>>> -
>>> /*
>>>  * XDR sizes, in quads
>>>  */
>>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>>> index 4fdeaac..45cb549 100644
>>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>>> @@ -75,11 +75,11 @@ static unsigned int rpcrdma_max_call_header_size(unsigned int maxsegs)
>>>
>>>        /* Maximum Read list size */
>>>        maxsegs += 2;   /* segment for head and tail buffers */
>>> -       size = maxsegs * sizeof(struct rpcrdma_read_chunk);
>>> +       size = maxsegs * rpcrdma_readchunk_maxsz * sizeof(__be32);
>>>
>>>        /* Minimal Read chunk size */
>>>        size += sizeof(__be32); /* segment count */
>>> -       size += sizeof(struct rpcrdma_segment);
>>> +       size += rpcrdma_segment_maxsz * sizeof(__be32);
>>>        size += sizeof(__be32); /* list discriminator */
>>>
>>>        dprintk("RPC:       %s: max call header size = %u\n",
>>> @@ -102,7 +102,7 @@ static unsigned int rpcrdma_max_reply_header_size(unsigned int maxsegs)
>>>        /* Maximum Write list size */
>>>        maxsegs += 2;   /* segment for head and tail buffers */
>>>        size = sizeof(__be32);          /* segment count */
>>> -       size += maxsegs * sizeof(struct rpcrdma_segment);
>>> +       size += maxsegs * rpcrdma_segment_maxsz * sizeof(__be32);
>>>        size += sizeof(__be32); /* list discriminator */
>>>
>>>        dprintk("RPC:       %s: max reply header size = %u\n",
>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> index 6e64c82..8b9954c 100644
>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> @@ -145,12 +145,6 @@ struct rpcrdma_regbuf {
>>>        return rb->rg_iov.lkey;
>>> }
>>>
>>> -static inline struct rpcrdma_msg *
>>> -rdmab_to_msg(struct rpcrdma_regbuf *rb)
>>> -{
>>> -       return (struct rpcrdma_msg *)rb->rg_base;
>>> -}
>>> -
>>> static inline struct ib_device *
>>> rdmab_device(struct rpcrdma_regbuf *rb)
>>> {
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
>
>
>
