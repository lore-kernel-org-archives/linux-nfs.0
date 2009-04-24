From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 13/29] nfsd41: free drc cache buffers
Date: Fri, 24 Apr 2009 10:11:44 -0400
Message-ID: <89c397150904240711t2c951dcch15435c216f6748ca@mail.gmail.com>
References: <1240504988-9572-5-git-send-email-andros@netapp.com>
	 <1240504988-9572-7-git-send-email-andros@netapp.com>
	 <1240504988-9572-8-git-send-email-andros@netapp.com>
	 <1240504988-9572-9-git-send-email-andros@netapp.com>
	 <1240504988-9572-10-git-send-email-andros@netapp.com>
	 <1240504988-9572-11-git-send-email-andros@netapp.com>
	 <1240504988-9572-12-git-send-email-andros@netapp.com>
	 <1240504988-9572-13-git-send-email-andros@netapp.com>
	 <1240504988-9572-14-git-send-email-andros@netapp.com>
	 <20090423233944.GN1906@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:28043 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757549AbZDXOLp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 10:11:45 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1008475wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 07:11:44 -0700 (PDT)
In-Reply-To: <20090423233944.GN1906@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 7:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Apr 23, 2009 at 12:42:52PM -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>
> This should probably be folded into the last patch.
>
> (For one reason: looks like applying everything up to the last patch
> would result in a kernel that leaked memory, since these things never
> got freed?  The rule here is that applying patches 1...n of any patch
> series should never introduce any new problems.)

OK

>
> --b.
>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfsd/nfs4state.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 9e79e0c..787cffe 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -590,7 +590,7 @@ free_session(struct kref *kref)
>>       ses = container_of(kref, struct nfsd4_session, se_ref);
>>       for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
>>               struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>> -             nfsd4_release_respages(e->ce_respages, e->ce_resused);
>> +             kfree(e->ce_datav.iov_base);
>>       }
>>       kfree(ses);
>>  }
>> --
>> 1.5.4.3
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
