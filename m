From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 018/100] nfsd: fail module init on reply cache init
	failure
Date: Mon, 28 Jan 2008 13:32:50 -0500
Message-ID: <20080128183250.GD16785@fieldses.org>
References: <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <D938EB81-E5CD-40D4-B302-738F561CF7BE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbYA1Scv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 13:32:51 -0500
In-Reply-To: <D938EB81-E5CD-40D4-B302-738F561CF7BE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 01:03:23PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>> If the reply cache initialization fails due to a kmalloc failure,
>> currently we try to soldier on with a reduced (or nonexistant) reply
>> cache.
>>
>> Better to just fail immediately: the failure is then much easier to
>> understand and debug, and it could save us complexity in some later
>> code.  (But actually, it doesn't help currently because the cache is
>> also turned off in some odd failure cases; we should probably find a
>> better way to handle those failure cases some day.)
>>
>> Fix some minor style problems while we're at it, and rename
>> nfsd_cache_init() to remove the need for a comment describing it.
>>
>> Acked-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/nfsd/nfscache.c         |   28 +++++++++++++---------------
>>  fs/nfsd/nfsctl.c           |   11 +++++++----
>>  include/linux/nfsd/cache.h |    4 ++--
>>  3 files changed, 22 insertions(+), 21 deletions(-)
>>
>> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
>> index 578f2c9..92cb5ae 100644
>> --- a/fs/nfsd/nfscache.c
>> +++ b/fs/nfsd/nfscache.c
>> @@ -44,17 +44,18 @@ static int	nfsd_cache_append(struct svc_rqst  
>> *rqstp, struct kvec *vec);
>>   */
>>  static DEFINE_SPINLOCK(cache_lock);
>>
>> -void
>> -nfsd_cache_init(void)
>> +int
>> +nfsd_reply_cache_init(void)
>
> I'm surprised this got by the style police.

Hmm.  checkpatch.pl doesn't seem to catch that.

Anyway, fair enough, fixed, and...

>>  void
>> -nfsd_cache_shutdown(void)
>> +nfsd_reply_cache_shutdown(void)
>
> Likewise.

... also fixed.  Thanks.

--b.
