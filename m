Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:43279 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751532AbeAZPRW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jan 2018 10:17:22 -0500
Received: by mail-ua0-f193.google.com with SMTP id i5so483454uai.10
        for <linux-nfs@vger.kernel.org>; Fri, 26 Jan 2018 07:17:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180125222902.GC21492@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <20171024174752.74910-6-kolga@netapp.com>
 <20180125222902.GC21492@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 26 Jan 2018 10:17:20 -0500
Message-ID: <CAN-5tyFP=kjLAyA+bAXHyk52=Ut5PO-DsBN=5ohRObUQekyN_Q@mail.gmail.com>
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 25, 2018 at 5:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Oct 24, 2017 at 01:47:47PM -0400, Olga Kornievskaia wrote:
>> +     copy->cp_clp = cstate->clp;
>> +     memcpy(&copy->fh, &cstate->current_fh.fh_handle,
>> +             sizeof(struct knfsd_fh));
>> +     copy->net = SVC_NET(rqstp);
>> +     if (!copy->cp_synchronous) {
>
> I was thinking we might want to do a synchronous copy anyway in some
> cases: e.g. if the copy is relatively small or if the filesystem
> supports clone.
>
> But I guess that's a premature optimization; better to keep this as you
> have it for now.

Let's keep it as is for now and complicate it later :-)

>
> --b.
>
>> +             status = nfsd4_init_copy_res(copy, 0);
>> +             async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>> +             if (!async_copy) {
>> +                     status = nfserrno(-ENOMEM);
>> +                     goto out;
>> +             }
>> +             dup_copy_fields(copy, async_copy);
>> +             memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
>> +                     sizeof(copy->cp_dst_stateid));
>> +             spin_lock(&async_copy->cp_clp->async_lock);
>> +             list_add(&async_copy->copies,
>> +                             &async_copy->cp_clp->async_copies);
>> +             spin_unlock(&async_copy->cp_clp->async_lock);
>> +             async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
>> +                             async_copy, "%s", "copy thread");
>> +             if (IS_ERR(async_copy->copy_task)) {
>> +                     status = PTR_ERR(async_copy->copy_task);
>> +                     goto out_err_dec;
>> +             }
>> +             wake_up_process(async_copy->copy_task);
>> +     } else {
>> +             status = nfsd4_do_copy(copy, 1);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
