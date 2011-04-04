Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33693 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755689Ab1DDUOy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Apr 2011 16:14:54 -0400
Message-ID: <4D9A26B8.6080504@netapp.com>
Date: Mon, 04 Apr 2011 16:14:48 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NeilBrown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
References: <20110316155528.31913c58@notabene.brown> <24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com> <4D80C5C6.2060003@netapp.com> <1300285203.16266.46.camel@lade.trondhjem.org> <20110317083034.479ecb5f@notabene.brown> <1300311755.30551.17.camel@lade.trondhjem.org> <20110317094019.23f31f53@notabene.brown> <20110317171831.GA30180@fieldses.org>
In-Reply-To: <20110317171831.GA30180@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've done some more testing and posted my initial results here: https://wiki.linux-nfs.org/wiki/index.php/Readdir_performance_results.  If anybody has suggestions for better ways to organize the data, please let me know.  I'll also try to post some graphs in the next couple of days.

- Bryan

On 03/17/2011 01:18 PM, J. Bruce Fields wrote:
> On Thu, Mar 17, 2011 at 09:40:19AM +1100, NeilBrown wrote:
>> On Wed, 16 Mar 2011 17:42:35 -0400 Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>
>>  
>>>> So it is obvious that there is sometimes value in using readdirplus,
>>>> it is equally obvious that there is sometimes a cost.
>>>>
>>>> Switching the default from "not paying the cost when it is big" to
>>>> "always paying the cost" is wrong.
>>>
>>> That's what the nordirplus mount flag is for. Keeping an arbitrary limit
>>> in the face of evidence that it is hurting is equally wrong.
>>>
>>
>> If people didn't need 'nordirplus' previously to get acceptable
>> performance, and do need it now, then that is a regression.
> 
> Agreed.
> 
> Unfortunately, reversion at this point would also be a regression for a
> different group of folks.  A smaller one, since *their* problem was
> fixed only more recently, but still there's probably no sensible way out
> of this but forwards....
> 
> --b.

