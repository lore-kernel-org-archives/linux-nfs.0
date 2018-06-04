Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:40685 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbeFDQ1w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 12:27:52 -0400
Received: by mail-wm0-f44.google.com with SMTP id n5-v6so3144374wmc.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 09:27:52 -0700 (PDT)
MIME-Version: 1.0
From: Rahul Deshmukh <rahul.deshmukh@gmail.com>
Date: Mon, 4 Jun 2018 21:57:50 +0530
Message-ID: <CAN88X1FR8EnrdwKq=w=yQx7Y=c=Ooek5RSGKODRvFQSZst-+eg@mail.gmail.com>
Subject: Question: On write code path
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello

I was just trying NFS + Lustre i.e. NFS running on Lustre, during this
experiment it is observed that the write requests that we get is not page
aligned even if the application is sending it correctly. Mostly it is the
first and last page which is not aligned.

After digging more into code it seems it is because of following code :

static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
{
        int i = 1;
        int buflen = write->wr_buflen;

        vec[0].iov_base = write->wr_head.iov_base;
        vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len); <======
        buflen -= vec[0].iov_len;

        while (buflen) {
                vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
                vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
                buflen -= vec[i].iov_len;
                i++;
        }
        return i;
}

nfsd4_write()
{
:
  nvecs = fill_in_write_vector(rqstp->rq_vec, write);
:
}

i.e. 0th vector is filled with min of buflen or wr_head and rest differently

Because of this, first and last page is not aligned.

The question here is, why 0th vector is separatly filled with
different size (as it
seems it is causing page un-alinged iovec) ? Or  am I missing any
thing at my end
because of un-alignment is seen ?


Thanks in advanced.
