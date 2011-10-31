Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40836 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932789Ab1JaRML (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 13:12:11 -0400
Received: by eye27 with SMTP id 27so5488337eye.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 10:12:10 -0700 (PDT)
Message-ID: <4EAED6E5.8090101@tonian.com>
Date: Mon, 31 Oct 2011 19:12:05 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Final disposition of the pNFSD tree
References: <4EA77E00.6090002@panasas.com> <4EA799BC.5050805@tonian.com>
In-Reply-To: <4EA799BC.5050805@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just released pnfs-all-3.1-2011-10-31 which is much stabler than
the 3.1-rc9+ versions.

If not too late, I think this would be the best version for you to test,
also with respect to the callback path which now works with the
revised layout stateid tracking mechanism.

Benny

On 2011-10-26 07:25, Benny Halevy wrote:
> On 2011-10-26 05:26, Boaz Harrosh wrote:
>> Benny what is the state of the PNFSD tree? Can you sign on it's stability for
>> a large scale testing or should I be using the nfsd-3.1 based tree?
>>
> 
> Right now there is use after free of the layout stateid that I'm working on
> for which I'd like to have a fix ASAP, before the end of the week
> that is due to the latest work done on top of bfields' for-3.2 patch set
> that I merged-in.
> 
>> As far as I could see. The last tree that did not have nfsd-3.2 
>> new state patches was pnfs-all-3.1-rc8-2011-10-06.
>>
>> pnfs-all-3.1-rc9-2011-10-17 Had some of them, but I guess not the major
>> ones. (Should I test with this one?)
> 
> Correct.  This version should be fine as it doesn't contain the stuff
> I mentioned above. (looking at alloc_init_layout_state() tells)
> 
>>
>> And pnfs-all-3.1-rc10-2011-10-18 (pnfs/pnfs-all-latest) has all of them.
>> Is it stable?
> 
> Nope, I sent it out during the Bakeathon hoping I'd be able to stabilize it
> on the spot but failed to do so.
> 
>>
>> My last heavy testing was actually on pnfs-all-3.1-rc6-2011-09-20. If I diff
>> that with pnfs-all-3.1-rc8-2011-10-06 on fs/nfsd/ I can still see huge amount
>> of for-nfsd-v3.2 changes. I know you have found some bugs, So I guess I'll stick
>> with the v3.1-rc6-pnfs based tree for the Server and v3.1 release Kernel + ore-v3.2
>> patches.
> 
> Sounds like a valid plan, though I always appreciate testing of the latest code
> where possible.  So if your testing with the older version goes fine and you still
> have some spare cycles to test the latest stable one it would be awesome.
> 
>>
>> Do you think you will release a 3.1 based pnfs tree that is completely based on
>> the v3.1-nfsd version and the old pnfs tree, without any for-v3.2-pnfsd patches?
> 
> No, I'll stabilize it as it is.  It seems scary because of the use-after-free bug trashes
> memory and causes havoc but it ain't so bad...
> 
> Benny
> 
>>
>> Thanks
>> Boaz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
