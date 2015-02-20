Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:41809 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193AbbBTR0T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2015 12:26:19 -0500
From: Nix <nix@esperi.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix> <87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<20150216145746.68809c0f@notabene.brown>
Date: Fri, 20 Feb 2015 17:26:12 +0000
In-Reply-To: <20150216145746.68809c0f@notabene.brown> (NeilBrown's message of
	"Mon, 16 Feb 2015 14:57:46 +1100")
Message-ID: <87h9ugqytn.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16 Feb 2015, NeilBrown uttered the following:

> On Mon, 16 Feb 2015 13:46:28 +1100 NeilBrown <neilb@suse.de> wrote:
>
>> Anyway, please try:
>> 
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index 9b0c55cb2a2e..a460669dc395 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
>>  
>>  		count++;
>>  
>> -		if (desc->plus != 0)
>> +		if (desc->plus != 0 && entry->fh.size)
>>  			nfs_prime_dcache(desc->file->f_path.dentry, entry);
>>  
>>  		status = nfs_readdir_add_to_array(entry, page);
>> 
>> 
>> which you might have to apply by hand.
>
> Make that "entry->fh->size", not "entry->fh.size" :-(

That looks to fix it (though my first day of testing was wasted because
I forgot nordirplus was in the mount options :/ ).

-- 
NULL && (void)
