From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 09/44] nfsd41: sanity check client drc maxreqs
Date: Tue, 16 Jun 2009 21:23:14 -0400
Message-ID: <89c397150906161823x3c6d821djd2d6ebb5d9725a9e@mail.gmail.com>
References: <1245115178-7097-1-git-send-email-bhalevy@panasas.com>
	 <20090617003538.GA8980@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, andros@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:10006 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbZFQBXM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 21:23:12 -0400
Received: by yw-out-2324.google.com with SMTP id 5so7199ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2009 18:23:14 -0700 (PDT)
In-Reply-To: <20090617003538.GA8980@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 8:35 PM, J. Bruce Fields<bfields@fieldses.org> wrote:
> On Tue, Jun 16, 2009 at 04:19:38AM +0300, Benny Halevy wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Ensure the client requested maximum requests are between 1 and
>> NFSD_MAX_SLOTS_PER_SESSION
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 582cd2c..90e6645 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -425,6 +425,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
>>  {
>>       int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
>>
>> +     if (fchan->maxreqs < 1)
>> +             return nfserr_inval;
>> +     else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
>> +             fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
>> +
>>       spin_lock(&nfsd_serv->sv_lock);
>
> How did this use of sv_lock creep in?  Let's remove that before we do
> anything else....

I remove it later.....

-->Andy

>
> --b.
>
>>       if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
>>               np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
>> --
>> 1.6.3
>>
>
