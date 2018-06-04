Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:56098 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbeFDSAe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 14:00:34 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Question: On write code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN88X1EcS4VoH+5P=r+HdTZcCdprnHmUt56h9pwiHhQ9L_6F6A@mail.gmail.com>
Date: Mon, 4 Jun 2018 14:00:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <171BD113-0AC9-430D-9B45-D68CC5DAFE39@oracle.com>
References: <CAN88X1FR8EnrdwKq=w=yQx7Y=c=Ooek5RSGKODRvFQSZst-+eg@mail.gmail.com>
 <209C26D7-4799-4273-8F88-02B43B82514B@oracle.com>
 <CAN88X1EcS4VoH+5P=r+HdTZcCdprnHmUt56h9pwiHhQ9L_6F6A@mail.gmail.com>
To: Rahul Deshmukh <rahul.deshmukh@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Rahul-

> On Jun 4, 2018, at 1:41 PM, Rahul Deshmukh <rahul.deshmukh@gmail.com> =
wrote:
>=20
> Hi Chuck,
>=20
> Thanks for the reply and confirming the understanding.
>=20
> Just want to understand any particular reason for not maintaining
> alignment for the case other than NFS/RDMA?

The RPC Call information and the payload appear contiguously in
the ingress data stream because that's how RPC over a stream
socket works (RFC 5531).

NFS/RDMA moves the NFS WRITE payload independently of incoming RPC
Calls, in a way that preserves the alignment of each data payload.

(Small NFS WRITEs with NFS/RDMA are basically datagrams, thus they
still need pull-up and data copy).


> Due to this any file system below NFS needs to handle this or suffer
> partial write.

Yes, I believe that's correct, and as far as I know the VFS is
capable of taking care of re-aligning the payload. This is not a
functional issue, but rather one of performance scalability.

The NFS/RDMA WRITE path is not perfect either, but thanks to the
aligned transfer of pages, there is an opportunity to fix it so
that correct page alignment can be maintained from the client
application all the way to the file system on the server. I'm
working in this area right now.


> Thanks.
> Rahul.
>=20
> On Mon, Jun 4, 2018 at 10:45 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On Jun 4, 2018, at 12:27 PM, Rahul Deshmukh =
<rahul.deshmukh@gmail.com> wrote:
>>>=20
>>> Hello
>>>=20
>>> I was just trying NFS + Lustre i.e. NFS running on Lustre, during =
this
>>> experiment it is observed that the write requests that we get is not =
page
>>> aligned even if the application is sending it correctly. Mostly it =
is the
>>> first and last page which is not aligned.
>>>=20
>>> After digging more into code it seems it is because of following =
code :
>>>=20
>>> static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write =
*write)
>>> {
>>>       int i =3D 1;
>>>       int buflen =3D write->wr_buflen;
>>>=20
>>>       vec[0].iov_base =3D write->wr_head.iov_base;
>>>       vec[0].iov_len =3D min_t(int, buflen, write->wr_head.iov_len); =
<=3D=3D=3D=3D=3D=3D
>>>       buflen -=3D vec[0].iov_len;
>>>=20
>>>       while (buflen) {
>>>               vec[i].iov_base =3D page_address(write->wr_pagelist[i =
- 1]);
>>>               vec[i].iov_len =3D min_t(int, PAGE_SIZE, buflen);
>>>               buflen -=3D vec[i].iov_len;
>>>               i++;
>>>       }
>>>       return i;
>>> }
>>>=20
>>> nfsd4_write()
>>> {
>>> :
>>> nvecs =3D fill_in_write_vector(rqstp->rq_vec, write);
>>> :
>>> }
>>>=20
>>> i.e. 0th vector is filled with min of buflen or wr_head and rest =
differently
>>>=20
>>> Because of this, first and last page is not aligned.
>>>=20
>>> The question here is, why 0th vector is separatly filled with
>>> different size (as it
>>> seems it is causing page un-alinged iovec) ? Or  am I missing any
>>> thing at my end
>>> because of un-alignment is seen ?
>>=20
>> The TCP transport fills the sink buffer from page 0 forward, =
contiguously.
>> The first page of that buffer contains the RPC and NFS header =
information,
>> then the first part of the NFS WRITE payload.
>>=20
>> The vector is built so that the 0th element points into the first =
page
>> right where the payload starts. Then it goes to the next page of the
>> buffer and starts at byte zero, and so on.
>>=20
>> NFS/RDMA can transport a payload while retaining its alignment.
>>=20
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



