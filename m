Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:45118 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbeFDRP0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 13:15:26 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Question: On write code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN88X1FR8EnrdwKq=w=yQx7Y=c=Ooek5RSGKODRvFQSZst-+eg@mail.gmail.com>
Date: Mon, 4 Jun 2018 13:15:21 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <209C26D7-4799-4273-8F88-02B43B82514B@oracle.com>
References: <CAN88X1FR8EnrdwKq=w=yQx7Y=c=Ooek5RSGKODRvFQSZst-+eg@mail.gmail.com>
To: Rahul Deshmukh <rahul.deshmukh@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 4, 2018, at 12:27 PM, Rahul Deshmukh <rahul.deshmukh@gmail.com> =
wrote:
>=20
> Hello
>=20
> I was just trying NFS + Lustre i.e. NFS running on Lustre, during this
> experiment it is observed that the write requests that we get is not =
page
> aligned even if the application is sending it correctly. Mostly it is =
the
> first and last page which is not aligned.
>=20
> After digging more into code it seems it is because of following code =
:
>=20
> static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write =
*write)
> {
>        int i =3D 1;
>        int buflen =3D write->wr_buflen;
>=20
>        vec[0].iov_base =3D write->wr_head.iov_base;
>        vec[0].iov_len =3D min_t(int, buflen, write->wr_head.iov_len); =
<=3D=3D=3D=3D=3D=3D
>        buflen -=3D vec[0].iov_len;
>=20
>        while (buflen) {
>                vec[i].iov_base =3D page_address(write->wr_pagelist[i - =
1]);
>                vec[i].iov_len =3D min_t(int, PAGE_SIZE, buflen);
>                buflen -=3D vec[i].iov_len;
>                i++;
>        }
>        return i;
> }
>=20
> nfsd4_write()
> {
> :
>  nvecs =3D fill_in_write_vector(rqstp->rq_vec, write);
> :
> }
>=20
> i.e. 0th vector is filled with min of buflen or wr_head and rest =
differently
>=20
> Because of this, first and last page is not aligned.
>=20
> The question here is, why 0th vector is separatly filled with
> different size (as it
> seems it is causing page un-alinged iovec) ? Or  am I missing any
> thing at my end
> because of un-alignment is seen ?

The TCP transport fills the sink buffer from page 0 forward, =
contiguously.
The first page of that buffer contains the RPC and NFS header =
information,
then the first part of the NFS WRITE payload.

The vector is built so that the 0th element points into the first page
right where the payload starts. Then it goes to the next page of the
buffer and starts at byte zero, and so on.

NFS/RDMA can transport a payload while retaining its alignment.


--
Chuck Lever



