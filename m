Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35493 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbbGBJmq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 05:42:46 -0400
Received: by pdbci14 with SMTP id ci14so42256925pdb.2
        for <linux-nfs@vger.kernel.org>; Thu, 02 Jul 2015 02:42:45 -0700 (PDT)
Message-ID: <5595078C.3050905@gmail.com>
Date: Thu, 02 Jul 2015 17:42:36 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>
CC: Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>, kinglongmee@gmail.com
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
References: <20150421215417.GE13782@fieldses.org>	<553781E2.1000900@gmail.com>	<20150422150703.GA1247@fieldses.org>	<20150423094431.1a8aa68b@notabene.brown>	<5538EB18.7080802@gmail.com>	<20150424130045.6bbdb2f9@notabene.brown>	<553E2784.6020906@gmail.com>	<20150429125728.69ddfc6c@notabene.brown>	<20150429191934.GA23980@fieldses.org>	<20150430075225.21a71056@notabene.brown>	<20150430213602.GB9509@fieldses.org>	<55483EB7.5060104@gmail.com>	<20150505141957.2aef920e@notabene.brown>	<55488006.6050502@gmail.com>	<558DDCB8.2020202@gmail.com> <20150627093559.28f604c3@noble>
In-Reply-To: <20150627093559.28f604c3@noble>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/27/2015 07:35, NeilBrown wrote:
> On Sat, 27 Jun 2015 07:14:00 +0800 Kinglong Mee <kinglongmee@gmail.com>
> wrote:
> 
>> ping ....
>>
>>> -----------------------------------------------------------------------------------
>>> >From d831154bb7e527f9003e16ac049526be5ed90228 Mon Sep 17 00:00:00 2001
>>> From: Kinglong Mee <kinglongmee@gmail.com>
>>> Date: Tue, 5 May 2015 16:24:16 +0800
>>> Subject: [PATCH] mountd: Case-insensitive path length must equals to parent
>>>
>>> Commit 6091c0a4c4 (mountd: add support for case-insensitive file names)
>>> introduces looking up bad path which is easy to trigger a present mutex race.
>>>
> 
> How do you know that every file system that treats multiple different
> strings as the same, imposes the rule that the strings must be the same
> length?

Agree with you.
With your suggestion, there is a bug exist.

static int is_subdirectory(char *child, char *parent)
{
        /* Check is child is strictly a subdirectory of
         * parent or a more distant descendant.
         */
        size_t l = strlen(parent);

# rpc.mountd get parent's length.

        if (strcmp(parent, "/") == 0 && child[1] != 0)
                return 1;

        return (same_path(child, parent, l) && child[l] == '/');

# will truncate child's name by parent's length, also checking child[l].
# I think the length should be calculated by the count of '/'.
}

> 
> Given how complex unicode case rules can be, I certainly wouldn't be
> certain of that.
> 
> If the only purpose of this patch is to avoid triggering a bug in a
> separate piece of code, then I am not in favour of it.

Yes,
This patch just change two condition's position.

Please ignore this patch,
maybe a new patch for NeilBrown's suggestion will be post.

thanks,
Kinglong Mee

> 
> Thanks,
> NeilBrown
> 
> 
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>> ---
>>>  utils/mountd/cache.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>> index 7d250f9..155695a 100644
>>> --- a/utils/mountd/cache.c
>>> +++ b/utils/mountd/cache.c
>>> @@ -478,7 +478,7 @@ static int is_subdirectory(char *child, char *parent)
>>>  	if (strcmp(parent, "/") == 0 && child[1] != 0)
>>>  		return 1;
>>>  
>>> -	return (same_path(child, parent, l) && child[l] == '/');
>>> +	return (child[l] == '/'	&& same_path(child, parent, l));
>>>  }
>>>  
>>>  static int path_matches(nfs_export *exp, char *path)
>>>
> 
> 
