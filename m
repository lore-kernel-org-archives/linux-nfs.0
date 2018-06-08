Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44824 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752692AbeFHPyK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Jun 2018 11:54:10 -0400
Date: Fri, 8 Jun 2018 11:54:10 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Rahul Deshmukh <rahul.deshmukh@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question: On write code path
Message-ID: <20180608155410.GA12719@fieldses.org>
References: <CAN88X1FR8EnrdwKq=w=yQx7Y=c=Ooek5RSGKODRvFQSZst-+eg@mail.gmail.com>
 <209C26D7-4799-4273-8F88-02B43B82514B@oracle.com>
 <CAN88X1EcS4VoH+5P=r+HdTZcCdprnHmUt56h9pwiHhQ9L_6F6A@mail.gmail.com>
 <171BD113-0AC9-430D-9B45-D68CC5DAFE39@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <171BD113-0AC9-430D-9B45-D68CC5DAFE39@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 04, 2018 at 02:00:29PM -0400, Chuck Lever wrote:
> Hi Rahul-
> 
> > On Jun 4, 2018, at 1:41 PM, Rahul Deshmukh <rahul.deshmukh@gmail.com> wrote:
> > 
> > Hi Chuck,
> > 
> > Thanks for the reply and confirming the understanding.
> > 
> > Just want to understand any particular reason for not maintaining
> > alignment for the case other than NFS/RDMA?
> 
> The RPC Call information and the payload appear contiguously in
> the ingress data stream because that's how RPC over a stream
> socket works (RFC 5531).

We set up the buffers and receive network data into them before we know
where in the request the write data might be.

I've been curious whether it might be possible to parse some of the data
as we receive it in svc_tcp_recvfrom().  NFSv4 compounds are potentially
very complicated, so it's not just a matter of reading a few bytes from
the header.  On the other hand, it's OK if we guess wrong sometimes, as
long as we guess right often enough to get a performance benefit.  Also
we might be able to use previous information about write data offsets
from this client to improve our guess.

It could be a fair amount of work to code and to test the performance
improvement, and I don't know whether it's worth the trouble or whether
we should tell people that care to use rdma....

--b.

> NFS/RDMA moves the NFS WRITE payload independently of incoming RPC
> Calls, in a way that preserves the alignment of each data payload.
> 
> (Small NFS WRITEs with NFS/RDMA are basically datagrams, thus they
> still need pull-up and data copy).
> 
> 
> > Due to this any file system below NFS needs to handle this or suffer
> > partial write.
> 
> Yes, I believe that's correct, and as far as I know the VFS is
> capable of taking care of re-aligning the payload. This is not a
> functional issue, but rather one of performance scalability.
> 
> The NFS/RDMA WRITE path is not perfect either, but thanks to the
> aligned transfer of pages, there is an opportunity to fix it so
> that correct page alignment can be maintained from the client
> application all the way to the file system on the server. I'm
> working in this area right now.
> 
> 
> > Thanks.
> > Rahul.
> > 
> > On Mon, Jun 4, 2018 at 10:45 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> 
> >> 
> >>> On Jun 4, 2018, at 12:27 PM, Rahul Deshmukh <rahul.deshmukh@gmail.com> wrote:
> >>> 
> >>> Hello
> >>> 
> >>> I was just trying NFS + Lustre i.e. NFS running on Lustre, during this
> >>> experiment it is observed that the write requests that we get is not page
> >>> aligned even if the application is sending it correctly. Mostly it is the
> >>> first and last page which is not aligned.
> >>> 
> >>> After digging more into code it seems it is because of following code :
> >>> 
> >>> static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >>> {
> >>>       int i = 1;
> >>>       int buflen = write->wr_buflen;
> >>> 
> >>>       vec[0].iov_base = write->wr_head.iov_base;
> >>>       vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len); <======
> >>>       buflen -= vec[0].iov_len;
> >>> 
> >>>       while (buflen) {
> >>>               vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
> >>>               vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
> >>>               buflen -= vec[i].iov_len;
> >>>               i++;
> >>>       }
> >>>       return i;
> >>> }
> >>> 
> >>> nfsd4_write()
> >>> {
> >>> :
> >>> nvecs = fill_in_write_vector(rqstp->rq_vec, write);
> >>> :
> >>> }
> >>> 
> >>> i.e. 0th vector is filled with min of buflen or wr_head and rest differently
> >>> 
> >>> Because of this, first and last page is not aligned.
> >>> 
> >>> The question here is, why 0th vector is separatly filled with
> >>> different size (as it
> >>> seems it is causing page un-alinged iovec) ? Or  am I missing any
> >>> thing at my end
> >>> because of un-alignment is seen ?
> >> 
> >> The TCP transport fills the sink buffer from page 0 forward, contiguously.
> >> The first page of that buffer contains the RPC and NFS header information,
> >> then the first part of the NFS WRITE payload.
> >> 
> >> The vector is built so that the 0th element points into the first page
> >> right where the payload starts. Then it goes to the next page of the
> >> buffer and starts at byte zero, and so on.
> >> 
> >> NFS/RDMA can transport a payload while retaining its alignment.
> >> 
> >> 
> >> --
> >> Chuck Lever
> >> 
> >> 
> >> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
