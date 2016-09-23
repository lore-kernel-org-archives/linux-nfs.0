Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36450 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751529AbcIWR7G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 13:59:06 -0400
Received: by mail-it0-f46.google.com with SMTP id o3so21932163ita.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 10:59:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
 <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Sep 2016 13:59:05 -0400
Message-ID: <CAN-5tyF3HrY9+xWO7HDnN_dv13vS9nqcp0vZpA29T=i3cJMSZg@mail.gmail.com>
Subject: Re: reuse of slot and seq# when RPC was interrupted
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 23, 2016 at 1:45 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Sep 23, 2016, at 13:40, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> If we instead bump the sequence number in the case of interrupted and do:
>
> You have no guarantees that the server has seen and processed the operation.

That is correct, i have tested the patch and made server never to
receive the operation and client have an interrupted slot. On the next
operation the server will complain back with SEQ_MISORDERED. Client
can recover from this operation. Client can not recover from "Remote
EIO".
