From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Restore missing hunk in NFS mount option parser
Date: Fri, 5 Sep 2008 17:44:23 -0400
Message-ID: <E1E3E616-8115-4EE0-978B-C55499B40E30@oracle.com>
References: <20080905181339.17103.36231.stgit@ingres.1015granger.net> <20080905211110.GE12947@fieldses.org> <76bd70e30809051425y21d1ce1kb06c8d72a83bdb4e@mail.gmail.com> <20080905213425.GH12947@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: chucklever@gmail.com, neilb@suse.de, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:58392 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbYIEVpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:45:31 -0400
In-Reply-To: <20080905213425.GH12947@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 5, 2008, at Sep 5, 2008, 5:34 PM, J. Bruce Fields wrote:
> On Fri, Sep 05, 2008 at 05:25:31PM -0400, Chuck Lever wrote:
>> On Fri, Sep 5, 2008 at 5:11 PM, J. Bruce Fields  
>> <bfields@fieldses.org> wrote:
>>> On Fri, Sep 05, 2008 at 02:16:07PM -0400, Chuck Lever wrote:
>>>> Commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a was missing a  
>>>> hunk that
>>>> prevented the new "sloppy" mount option from having any effect.
>>>
>>> I don't think that on its own would justify sending it in for  
>>> 2.6.27.[1]
>>
>> The original patch for 27 was supposed to fix a regression (ie
>> automounter stopped working in heterogenous environments).  This  
>> patch
>> does fix the full regression.
>>
>> There is already logic in nfs-utils-1.1.3 that maps the "-s" option
>> (which has been around for EVAR) to "-o sloppy".  This logic is
>> enabled for 2.6.27 kernels and later.  So this does need to go in 27.
>>
>> Would it help if I rewrote the description?
>
> Could be.  Assume I'm tired and stupid....
>
>>>> Tested against 2.6.27-rc.  2.6.26 is not affected.
>>>
>>> But if I understand right, the effect of leaving out this chunk  
>>> was to
>>> make the *default* behavior "sloppy"?  Which seems a drastic  
>>> change from
>>> the previous behavior.  And it's a simple enough patch.
>>
>> No, the default behavior is as before.  The behavior without this
>> patch is that the kernel recognizes "sloppy" but it doesn't do
>> anything about it.
>
> That can't be right:
>
>>>> +     if (errors > 0) {
>>>> +             dfprintk(MOUNT, "NFS: parsing encountered %d error%s 
>>>> \n",
>>>> +                             errors, (errors == 1 ? "" : "s"));
>>>> +             if (!sloppy)
>>>> +                     return 0;
>>>> +     }
>>>>      return 1;
>
> Ignoring the printk, the *only* change in behavior here happens when
> sloppy is *not* set.  Right?


Hrm.  Without today's patch, the behavior is always sloppy, and  
"sloppy" is recognized as a valid option (not that it matters).  With  
the patch, the default behavior is as before, and the sloppy option is  
recognized.

So yes, this is a regression in both senses.


I'll rewrite the description and repost.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
