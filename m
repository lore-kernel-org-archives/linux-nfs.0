Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14438 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab2LDP6I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2012 10:58:08 -0500
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id qB4Fw7Vt006485
	for <linux-nfs@vger.kernel.org>; Tue, 4 Dec 2012 07:58:07 -0800 (PST)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: new keyring key_type for gss context
 destruction at kdestroy
Date: Tue, 4 Dec 2012 15:58:05 +0000
Message-ID: <7851A663D3BF5E41B9E166C2C7A42145104F6C13@SACEXCMBX02-PRD.hq.netapp.com>
References: <1354560315-2393-1-git-send-email-andros@netapp.com>
 <1354560315-2393-2-git-send-email-andros@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90B334027@SACEXCMBX04-PRD.hq.netapp.com>
 <7851A663D3BF5E41B9E166C2C7A42145104F61E8@SACEXCMBX02-PRD.hq.netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90B33595E@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B33595E@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 4, 2012, at 9:56 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Mon, 2012-12-03 at 22:39 +0000, Adamson, Andy wrote:
>> On Dec 3, 2012, at 4:06 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>> wrote:
> 
>>> It seems to me that this code allows me to kill anyone's rpcsec_gss
>>> sessions by creating a key with their uid, and then destroying it.
>> 
>> Yes - just proof of concept code. There is a lot to consider.
>> 
>>> 
>>> One solution is to replace user_instantiate() with something that sets
>>> the payload to a value determined by the kernel itself. We'd definitely
>>> want to include the uid, but perhaps also add a cookie that is unique to
>>> this key (using the idr/ida stuff from include/linux/idr.h ?), and that
>>> can be used to distinguish it from keys generated from other processes.
>>> If we were to use the same key to label the auth_gss creds, then we
>>> could have user_gss_destroy() kill _only_ the auth_gss creds that it
>>> spawned.
>> 
>> Yes, killing only the auth it spawned is indeed what we want.
>> 
>>> 
>>> Ultimately, though, I think we might want to let the user set at least
>>> _part_ of the payload to something that might be useful to gssd when it
>>> goes looking for credentials. Since the nfslogin and gssd will be
>>> shipped as part of the nfs-utils package, it would be nice to allow them
>>> to use the gss-ctx key in order to communicate. Interesting information
>>> might include the KRB5CCNAME.
>> 
>> Thanks for the good suggestions.
> 
> So, I've got a question: Can we replace some of the stuff in the "RFC
> Avoid expired credential keys for buffered writes" patch series with
> this?
> 
> My thinking is that since the user_gss_destroy() has to sync all files
> and then invalidate the rpcsec_gss creds, we're pretty much doing the
> same thing as in the above RFC patch series.

I was thinking the other way 'round. When gss_user_destroy gets called due to nfslogout (kdestroy) it triggers the RPC avoid expiration on buffered writes code with one difference: It does not allow _any_ new writes or _any_ other RPCs to use a GSS context  with a valid lifetime but to be destroyed due to logout. 

So instead of gss_user_destroy marking a GSS context as out of date, it will be marked as to be ONLY used for flushing writes that were buffered before the nfslogout (kdestroy) and associated commits.

> If nfslogin were to tell
> the gss-ctx key how long until the kerberos tgt expires,

We already have an expired time for the TGT in the GSS context downcall. Why do we need nfslogin to repeat the information? If you want to have a work queue job wake up based on the TGT lifetime, the info is already in the GSS context.

> couldn't we
> have a work queue job wake up just before the tgt is about to expire,
> and simply call user_gss_destroy by revoking the gss-ctx key?

I think using  the TGT lifetime that existed to at the creation of the GSS context trigger the RPC avoid cred expiration code works really well. I don't see a need for a workqueue thread.

> If, on the other hand, the user renews the tgt using nfslogin,

Yes - this is in plan. nfslogin (e.g. TGT renewal) will update an existing gss-ctx key which in turn will trigger an upcall on associated GSS contexts to have them renewed.  I didn't want to bother with this until the idea of nfslogin/nfslogout had been flown :)

> then we
> could update the gss-ctx key, and defer the work queue job until the new
> expirt time.

With nfslogin updating the GSS context, the same will happen with the current RPC avoid expired cred code.

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

