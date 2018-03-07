Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:42749 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754039AbeCGVyw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 16:54:52 -0500
Received: by mail-ua0-f169.google.com with SMTP id b23so2528548uak.9
        for <linux-nfs@vger.kernel.org>; Wed, 07 Mar 2018 13:54:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180307214336.GD28844@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com> <20180220164229.65404-7-kolga@netapp.com>
 <20180307214336.GD28844@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 7 Mar 2018 16:54:50 -0500
Message-ID: <CAN-5tyE9++KkQs064P25NtYkX6L03sNinhVU4Xg41cX_j_EfXg@mail.gmail.com>
Subject: Re: [PATCH v7 06/10] NFSD return nfs4_stid in nfs4_preprocess_stateid_op
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 7, 2018 at 4:43 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Feb 20, 2018 at 11:42:25AM -0500, Olga Kornievskaia wrote:
>> @@ -5143,8 +5144,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>>       if (!status && filpp)
>>               status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
>>  out:
>> -     if (s)
>> +     if (s) {
>> +             if (!status && cstid)
>> +                     *cstid = s;
>>               nfs4_put_stid(s);
>
> Are you sure that's right?  Normally you wouldn't drop a reference on
> something you're returning.

Hm. Should it be taken here then? I do up the reference on the stateid
later in the code in the nfds4_copy().
