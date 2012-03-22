Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55820 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab2CVWMB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 18:12:01 -0400
Message-ID: <4F6BA3A2.1090501@panasas.com>
Date: Thu, 22 Mar 2012 15:11:46 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Change the default setting of the nfs4_disable_idmapping
 parameter
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com> <20120322204705.GA23737@fieldses.org> <1332449607.8976.9.camel@lade.trondhjem.org> <1332450074.8976.13.camel@lade.trondhjem.org> <20120322212616.GD23737@fieldses.org>
In-Reply-To: <20120322212616.GD23737@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/22/2012 02:26 PM, J. Bruce Fields wrote:
> On Thu, Mar 22, 2012 at 09:01:12PM +0000, Myklebust, Trond wrote:
>> On Thu, 2012-03-22 at 16:53 -0400, Trond Myklebust wrote:
>>> Does the idmapper do the right thing for numeric ids these days? If the
>>> older clients are running a newer idmapper that can deal with numeric
>>> ids, then even the legacy clients should be able to work cleanly.
>>
>> If this isn't the case, then the older clients are broken anyway. The
>> server has always had the option of returning numeric ids if it has no
>> mapping from a uid/gid into an owner/group string.
> 
> Hm, yes, but I was worried that the id<->name mapping might just be
> different on the two sides--but if that's so, and they were using
> auth_sys, then they likely already had problems.
> 
> So, maybe we could default this to on.
> 
> If that's the case then I'd rather not bother making this per export:
> just an option to get the server back to its previous behavior would
> seem enough.
> 
> --b.
> 
>> IOW: the only difference between older and newer clients should really
>> be that the newer ones handle numeric strings more efficiently without
>> requiring an upcall, and that the newer clients will also try to _send_
>> numeric ids in SETATTR calls.
>>

I was thinking about this too. Trond was making this clearer. 

Could we have an on/off/auto option? on the server.

The auto option is start with off, and if the client 
"_send_ numeric ids in SETATTR calls" then this client will start to be
treated as on.

Though now that I see it in writing it looks too complicated. Just a crazy
thought I had.

If you ask me I vote for default on, because where it makes a difference
from my experience with old Server the setup had a problem. Now all of a
sudden it will magically work. I fail to see an opposite scenario where
the brokenness was good, and now it will be bad.

Thanks
Boaz

>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

