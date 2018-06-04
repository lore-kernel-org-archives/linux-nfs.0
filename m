Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:46455 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbeFDRlO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 13:41:14 -0400
Received: by mail-wr0-f178.google.com with SMTP id v13-v6so33381772wrp.13
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 10:41:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <209C26D7-4799-4273-8F88-02B43B82514B@oracle.com>
References: <CAN88X1FR8EnrdwKq=w=yQx7Y=c=Ooek5RSGKODRvFQSZst-+eg@mail.gmail.com>
 <209C26D7-4799-4273-8F88-02B43B82514B@oracle.com>
From: Rahul Deshmukh <rahul.deshmukh@gmail.com>
Date: Mon, 4 Jun 2018 23:11:12 +0530
Message-ID: <CAN88X1EcS4VoH+5P=r+HdTZcCdprnHmUt56h9pwiHhQ9L_6F6A@mail.gmail.com>
Subject: Re: Question: On write code path
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Thanks for the reply and confirming the understanding.

Just want to understand any particular reason for not maintaining
alignment for the case other than NFS/RDMA?

Due to this any file system below NFS needs to handle this or suffer
partial write.

Thanks.
Rahul.

On Mon, Jun 4, 2018 at 10:45 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On Jun 4, 2018, at 12:27 PM, Rahul Deshmukh <rahul.deshmukh@gmail.com> wrote:
>>
>> Hello
>>
>> I was just trying NFS + Lustre i.e. NFS running on Lustre, during this
>> experiment it is observed that the write requests that we get is not page
>> aligned even if the application is sending it correctly. Mostly it is the
>> first and last page which is not aligned.
>>
>> After digging more into code it seems it is because of following code :
>>
>> static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>> {
>>        int i = 1;
>>        int buflen = write->wr_buflen;
>>
>>        vec[0].iov_base = write->wr_head.iov_base;
>>        vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len); <======
>>        buflen -= vec[0].iov_len;
>>
>>        while (buflen) {
>>                vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
>>                vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
>>                buflen -= vec[i].iov_len;
>>                i++;
>>        }
>>        return i;
>> }
>>
>> nfsd4_write()
>> {
>> :
>>  nvecs = fill_in_write_vector(rqstp->rq_vec, write);
>> :
>> }
>>
>> i.e. 0th vector is filled with min of buflen or wr_head and rest differently
>>
>> Because of this, first and last page is not aligned.
>>
>> The question here is, why 0th vector is separatly filled with
>> different size (as it
>> seems it is causing page un-alinged iovec) ? Or  am I missing any
>> thing at my end
>> because of un-alignment is seen ?
>
> The TCP transport fills the sink buffer from page 0 forward, contiguously.
> The first page of that buffer contains the RPC and NFS header information,
> then the first part of the NFS WRITE payload.
>
> The vector is built so that the 0th element points into the first page
> right where the payload starts. Then it goes to the next page of the
> buffer and starts at byte zero, and so on.
>
> NFS/RDMA can transport a payload while retaining its alignment.
>
>
> --
> Chuck Lever
>
>
>
