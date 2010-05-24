From: Stuart Sheldon <stu-7mM24aH7KjCsTnJN9+BGXg@public.gmane.org>
Subject: Re: Possible NFS bug in 2.6.34...
Date: Mon, 24 May 2010 08:29:54 -0700
Message-ID: <4BFA9B72.1070000@actusa.net>
References: <4BF72D34.60701@actusa.net>	 <1274544580.4860.73.camel@heimdal.trondhjem.org>	 <4BF803F2.2010506@actusa.net> <1274546973.4860.78.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Stuart Sheldon <stu-7mM24aH7KjCsTnJN9+BGXg@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from internal.actusa.net ([208.83.100.16]:59265 "EHLO
	internal.actusa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606Ab0EXPaR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 11:30:17 -0400
In-Reply-To: <1274546973.4860.78.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Trond Myklebust wrote:
> On Sat, 2010-05-22 at 09:18 -0700, Stuart Sheldon wrote: 
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA256
>>
>> On 05/22/2010 09:09 AM, Trond Myklebust wrote:
>>> Do you see any more NFS traffic to the server when the above hang
>>> occurs? I'm wondering if we don't need something like the following
>>> patch.
>>>
>>> Cheers
>>>   Trond 
>>> --------------------------------------------------------------------------------
>>> From 0b574497e05f62fd49cfe26f1b97e3669525446c Mon Sep 17 00:00:00 2001
>>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Date: Sat, 22 May 2010 11:49:19 -0400
>>> Subject: [PATCH] NFS: Ensure that we mark the inode as dirty if we exit early from commit
>>>
>>> If we exit from nfs_commit_inode() without ensuring that the COMMIT rpc
>>> call has been completed, we must re-mark the inode as dirty. Otherwise,
>>> future calls to sync_inode() with the WB_SYNC_ALL flag set will fail to
>>> ensure that the data is on the disk.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Cc: stable@kernel.org
>>> ---
>>>  fs/nfs/write.c |   13 +++++++++++--
>>>  1 files changed, 11 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>> index 3aea3ca..b8a6d7a 100644
>>> --- a/fs/nfs/write.c
>>> +++ b/fs/nfs/write.c
>>> @@ -1386,7 +1386,7 @@ static int nfs_commit_inode(struct inode *inode, int how)
>>>  	int res = 0;
>>>  
>>>  	if (!nfs_commit_set_lock(NFS_I(inode), may_wait))
>>> -		goto out;
>>> +		goto out_mark_dirty;
>>>  	spin_lock(&inode->i_lock);
>>>  	res = nfs_scan_commit(inode, &head, 0, 0);
>>>  	spin_unlock(&inode->i_lock);
>>> @@ -1398,9 +1398,18 @@ static int nfs_commit_inode(struct inode *inode, int how)
>>>  			wait_on_bit(&NFS_I(inode)->flags, NFS_INO_COMMIT,
>>>  					nfs_wait_bit_killable,
>>>  					TASK_KILLABLE);
>>> +		else
>>> +			goto out_mark_dirty;
>>>  	} else
>>>  		nfs_commit_clear_lock(NFS_I(inode));
>>> -out:
>>> +	return res;
>>> +	/* Note: If we exit without ensuring that the commit is complete,
>>> +	 * we must mark the inode as dirty. Otherwise, future calls to
>>> +	 * sync_inode() with the WB_SYNC_ALL flag set will fail to ensure
>>> +	 * that the data is on the disk.
>>> +	 */
>>> +out_mark_dirty:
>>> +	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>>>  	return res;
>>>  }
>>>  
>> Trond,
>>
>> When it occurred, it continues to throw those errors in the log, and all
>> access to the NFS mount stalled until I hard reset the client system.
>>
>> Do you want me to apply the patch and see if I can recreate the condition?
> 
> Yes, please do. Could you also apply the following debugging patch on
> top of the above one, and see if the WARN_ON() triggers when both
> patches are applied?
> 
> Cheers
>   Trond 
> ------------------------------------------------------------------------------------------------
> From 9883e35957468987f4338525c1d800d637bc05b7 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sat, 22 May 2010 10:46:41 -0400
> Subject: [PATCH 2/2] NFS: debugging code for nfs_wb_page()
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/write.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b8a6d7a..0558fab 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1519,12 +1519,21 @@ int nfs_wb_page(struct inode *inode, struct page *page)
>  	int ret;
>  
>  	while(PagePrivate(page)) {
> +		unsigned dirty;
> +		int syncing;
> +
>  		wait_on_page_writeback(page);
>  		if (clear_page_dirty_for_io(page)) {
>  			ret = nfs_writepage_locked(page, &wbc);
>  			if (ret < 0)
>  				goto out_error;
> +			continue;
>  		}
> +
> +		dirty = inode->i_state & I_DIRTY;
> +		syncing = inode->i_state & I_SYNC;
> +		WARN_ON(!syncing && !dirty && PagePrivate(page));
> +
>  		ret = sync_inode(inode, &wbc);
>  		if (ret < 0)
>  			goto out_error;

Ok,

I was able to reproduce the problem, and then repeat the test with the
patched kernel. The result with the patched kernel was that the system
did not crash, but I did not see any of the WARN_ON messages in the
logs. Also, I noticed that although the client did not crash, I did
notice long 'hangs' in the process...

Just a note, when I upgraded from 2.6.30.5 to 2.6.33.2 I noticed that
our overall network activity for NFS increase by about 40%. Also, I saw
longer delays when using commands like ls on a NFS mounted partition.
Not sure if anyone else noticed this or not, but I thought it worth
mentioning... :)

Stu


- --
Spider Pig, Spider Pig, Does whatever a Spider Pig does.
Can he swing, from a web, no he can't, he's a pig.
Look Oouuuut! He is a Spider Pig....
		-- Matt Groening - "Spider Pig Lyrics"
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAEBCAAGBQJL+ptvAAoJEFKVLITDJSGSjGEP/27W6Eb19ACogC1F4OY/KsEj
dMC0qKZeV2pJFV9UH4c8pH0TvTwNGLrcFk36wzzyuTKqyaYaBKB9iXEsy4XrLc2i
pSLh5/fjsd8zuf44ZEu9jEUvpUjpZoMnvWbYdZ0FMeCEcg+h8enf7OTVxCMtJeY6
1tiSifcrrWxiwfE6rsS7dAldWLuic4vQw4dC53RC1RcwHTewVmK3penHlPbaGZoe
UHYL1nuHek8pmlluMvATaY4qwu5teBGqru1c8Xrm7RsaSZCU4gSZNG83uv+hRKfk
TRBIIi1kZ54CV7h6flNf/Byb4xw7uOGtQ9mgM1Nqupdh1faoAAbnXEhz2AOLEg51
yadnctCrTOHXIvwblPVRz8o77JB8UU8EU4KJjTBg/Dy4JJsbe3XNNY2gusy6QCPQ
7n0oq5x0eZGdy5CGAYqm9L3zhaxIPs/2Wxkav+snh7GsED+tcnbwv7gdtTN8bRrW
dH5fsX7X/vdmr6hRpQhFshiZTjbZD5Zn2q0FZDspVyMHLuE+mjUY+G/82P17SfGi
OAC4mclbsPkoGvcHLBuXgCFdCEmWsJxSZNTykfCj34+DaDMSZ+s1zcGvd63f8PiG
xkxU+ADBqfNcRcJ6XuHOqWFGuVuN3MDbriIidiCZwI7uFW/qx7X0yR78aRgaXqCV
19zpRpMOBaVPmtdLdadQ
=zl3B
-----END PGP SIGNATURE-----
