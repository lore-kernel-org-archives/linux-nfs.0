Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36838 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdIMOis (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Sep 2017 10:38:48 -0400
Received: by mail-it0-f65.google.com with SMTP id e134so468058ite.3
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 07:38:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170906213703.GE24694@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com> <20170711164416.1982-26-kolga@netapp.com>
 <20170906213703.GE24694@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 13 Sep 2017 10:38:46 -0400
Message-ID: <CAN-5tyGcU7O_w08v5t1D4-C34XvdbR-Xf9pKNX7NCS=zYb9tGA@mail.gmail.com>
Subject: Re: [RFC v3 25/42] NFSD add COPY_NOTIFY operation
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 6, 2017 at 5:37 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jul 11, 2017 at 12:43:59PM -0400, Olga Kornievskaia wrote:
>> +struct nfsd4_copy_notify {
>> +     /* request */
>> +     stateid_t               cpn_src_stateid;
>> +     struct nl4_server       cpn_dst;
>> +
>> +     /* response */
>> +     /* Note: cpn_src_stateid is used for cnr_stateid */
>
> That might be worth a little more explanation.

I'm opting for removing it from this patch? It's just valid for that
patch saying that for the
moment the same cpn_src_stateid is returned fort he cnr_stateid in the
later patch (29)
we will add the generation of the unique stateid used for the copy.

>
> --b.
>
>> +     u64                     cpn_sec;
>> +     u32                     cpn_nsec;
>> +     struct nl4_servers      cpn_src;
>> +};
>> +
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
