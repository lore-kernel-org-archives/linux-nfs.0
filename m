Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34921 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756782AbbEEIdg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 04:33:36 -0400
Received: by pdbqd1 with SMTP id qd1so188674077pdb.2
        for <linux-nfs@vger.kernel.org>; Tue, 05 May 2015 01:33:35 -0700 (PDT)
Message-ID: <55488006.6050502@gmail.com>
Date: Tue, 05 May 2015 16:32:06 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Steve Dickson <SteveD@redhat.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
References: <20150421215417.GE13782@fieldses.org>	<553781E2.1000900@gmail.com>	<20150422150703.GA1247@fieldses.org>	<20150423094431.1a8aa68b@notabene.brown>	<5538EB18.7080802@gmail.com>	<20150424130045.6bbdb2f9@notabene.brown>	<553E2784.6020906@gmail.com>	<20150429125728.69ddfc6c@notabene.brown>	<20150429191934.GA23980@fieldses.org>	<20150430075225.21a71056@notabene.brown>	<20150430213602.GB9509@fieldses.org>	<55483EB7.5060104@gmail.com> <20150505141957.2aef920e@notabene.brown>
In-Reply-To: <20150505141957.2aef920e@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/5/2015 12:19 PM, NeilBrown wrote:
> On Tue, 05 May 2015 11:53:27 +0800 Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> Cc Steve, Viro,
>>
>> On 5/1/2015 5:36 AM, J. Bruce Fields wrote:
>>> On Thu, Apr 30, 2015 at 07:52:25AM +1000, NeilBrown wrote:
>>>> On Wed, 29 Apr 2015 15:19:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
>>>> wrote:
>>>>> Maybe drop the locking from nfsd_buffered_readdir and *just* take the
>>>>> i_mutex around lookup_one_len(), if that's the only place we need it?
>>
>> As description in other thread, before the upcall to rpc.mountd,
>> nfsd have call lookup_one_len() for the file, but why rpc.mountd
>> also blocked in lookup ?
>>
>> There is a bug in rpc.mountd when checking sub-directory, 
>> it sets bad patch length for child.
>>
>> If parent if "/nfs/xfs" and child is "/nfs/test", the child name
>> will be truncated to "/nfs/tes" for strlen(parent), "/nfs/test"
>> have exist in kernel's cache for the lookup_one_len(), but
>> "/nfs/tes" is a bad path, which needs lookup_slow(), so blocked.
> 
> Testing for "/nfs/tes" certain seems like a wrong thing to do.
> 
>>
>> static int is_subdirectory(char *child, char *parent)
>> {
>>         /* Check is child is strictly a subdirectory of
>>          * parent or a more distant descendant.
>>          */
>>         size_t l = strlen(parent);
>>
>>         if (strcmp(parent, "/") == 0 && child[1] != 0)
>>                 return 1;
>>
>>         return (same_path(child, parent, l) && child[l] == '/');
> 
> I guess this should be:
> 
>           child[l] == '/' && same_path(child, parent, l)
> 
> That way there would be no risk of truncating anything.
> 
> Can you please test if that one-line change removes the problem?

Yes, that's OK.
I have think about the "/nfs/nfs" and "/nfs/123" of the first patch,
yes, that's redundant.

> 
>> }
>>
>> The following path makes a correct path, not a truncated path.
>> Have be tested, everything is OK.
>>
>> thanks,
>> Kinglong Mee
>>
>> -----------------------------------------------------------------------------------
>> >From 70b9d1d93a24db8a7837998cb7eb0ff4e98480a6 Mon Sep 17 00:00:00 2001
>> From: Kinglong Mee <kinglongmee@gmail.com>
>> Date: Tue, 5 May 2015 11:47:20 +0800
>> Subject: [PATCH] mountd: Case-insensitive path length must equal to parent
>>
>> Commit 6091c0a4c4 (mountd: add support for case-insensitive file names)
>> introdues a bug cause mutex race when looking bad path.
> 
> I think we should be clear that the mutex race is already present.
> I think you are right that there is a bug here which is making it easy to
> trigger, but it isn't exactly "causing" the bug.

Thanks for the comments.

thanks,
Kinglong Mee

-----------------------------------------------------------------------------------
