From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 022/100] nfsd: move cache proc (un)registration to
	separate function
Date: Mon, 28 Jan 2008 16:31:05 -0500
Message-ID: <20080128213105.GM16785@fieldses.org>
References: <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <1201303040-7779-21-git-send-email-bfields@citi.umich.edu> <1201303040-7779-22-git-send-email-bfields@citi.umich.edu> <1B8DF3CC-4C08-49B0-B035-57F40B4E846A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37798 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbYA1VbG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 16:31:06 -0500
In-Reply-To: <1B8DF3CC-4C08-49B0-B035-57F40B4E846A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 02:40:30PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> Just some minor cleanup.
>>
>> Also I don't see much point in trying to register further proc entries
>> if initial entries fail; so just stop trying in that case.
>>
>> Acked-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  net/sunrpc/cache.c |   99 +++++++++++++++++++++++++++ 
>> +-----------------------
>>  1 files changed, 54 insertions(+), 45 deletions(-)
>>
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index d05ea16..504b4e8 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -290,44 +290,63 @@ static const struct file_operations  
>> cache_flush_operations;
>>  static void do_cache_clean(struct work_struct *work);
>>  static DECLARE_DELAYED_WORK(cache_cleaner, do_cache_clean);
>>
>> -void cache_register(struct cache_detail *cd)
>> +void remove_cache_proc_entries(struct cache_detail *cd)
>
> Since you don't provide an EXPORT_SYMBOL for this new function, perhaps 
> it should be declared static?
>
>>  {
>> -	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
>> -	if (cd->proc_ent) {
>> -		struct proc_dir_entry *p;
>> -		cd->proc_ent->owner = cd->owner;
>> -		cd->channel_ent = cd->content_ent = NULL;
>> +	if (cd->proc_ent == NULL)
>> +		return;
>> +	if (cd->flush_ent)
>> +		remove_proc_entry("flush", cd->proc_ent);
>> +	if (cd->channel_ent)
>> +		remove_proc_entry("channel", cd->proc_ent);
>> +	if (cd->content_ent)
>> +		remove_proc_entry("content", cd->proc_ent);
>> +	cd->proc_ent = NULL;
>> +	remove_proc_entry(cd->name, proc_net_rpc);
>> +}
>>
>> -		p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR,
>> -				      cd->proc_ent);
>> -		cd->flush_ent =  p;
>> -		if (p) {
>> -			p->proc_fops = &cache_flush_operations;
>> -			p->owner = cd->owner;
>> -			p->data = cd;
>> -		}
>> +void create_cache_proc_entries(struct cache_detail *cd)
>
> Likewise.

Whoops, yes, fixed.

--b.
