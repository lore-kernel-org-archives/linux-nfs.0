Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:17794 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab1LGIrI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 03:47:08 -0500
Message-ID: <4EDF2805.3090700@parallels.com>
Date: Wed, 07 Dec 2011 12:47:01 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "neilb@suse.de" <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSd: use network-namespace-aware cache registering routines
References: <20111206130330.25851.55807.stgit@localhost6.localdomain6> <20111206210234.GC12640@fieldses.org> <20111206211450.GD12640@fieldses.org>
In-Reply-To: <20111206211450.GD12640@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

07.12.2011 01:14, J. Bruce Fields пишет:
> On Tue, Dec 06, 2011 at 04:02:34PM -0500, J. Bruce Fields wrote:
>> On Tue, Dec 06, 2011 at 05:04:31PM +0300, Stanislav Kinsbursky wrote:
>>> This is a cleanup patch. Some day (hope, soon enough) generic cache_register()
>>> and cache_unregister() will be removed.
>>
>> OK, applying for 3.3.--b.
>
> Whoops, no I'm not, these make modular builds fail.  Looks like we need
> a couple EXPORT_SYMBOL_GPL()'s.  Could you resend?
>

Sorry. My fault (I exported these symbols in other patch).
Will resend soon.

> --b.
>
>>
>>>
>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>
>>> ---
>>>   fs/nfsd/export.c    |   10 +++++-----
>>>   fs/nfsd/nfs4idmap.c |   11 ++++++-----
>>>   2 files changed, 11 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>>> index 62f3b90..d1feeef 100644
>>> --- a/fs/nfsd/export.c
>>> +++ b/fs/nfsd/export.c
>>> @@ -1226,12 +1226,12 @@ nfsd_export_init(void)
>>>   	int rv;
>>>   	dprintk("nfsd: initializing export module.\n");
>>>
>>> -	rv = cache_register(&svc_export_cache);
>>> +	rv = cache_register_net(&svc_export_cache,&init_net);
>>>   	if (rv)
>>>   		return rv;
>>> -	rv = cache_register(&svc_expkey_cache);
>>> +	rv = cache_register_net(&svc_expkey_cache,&init_net);
>>>   	if (rv)
>>> -		cache_unregister(&svc_export_cache);
>>> +		cache_unregister_net(&svc_export_cache,&init_net);
>>>   	return rv;
>>>
>>>   }
>>> @@ -1255,8 +1255,8 @@ nfsd_export_shutdown(void)
>>>
>>>   	dprintk("nfsd: shutting down export module.\n");
>>>
>>> -	cache_unregister(&svc_expkey_cache);
>>> -	cache_unregister(&svc_export_cache);
>>> +	cache_unregister_net(&svc_expkey_cache,&init_net);
>>> +	cache_unregister_net(&svc_export_cache,&init_net);
>>>   	svcauth_unix_purge();
>>>
>>>   	dprintk("nfsd: export shutdown complete.\n");
>>> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
>>> index 55780a2..9409627 100644
>>> --- a/fs/nfsd/nfs4idmap.c
>>> +++ b/fs/nfsd/nfs4idmap.c
>>> @@ -36,6 +36,7 @@
>>>   #include<linux/seq_file.h>
>>>   #include<linux/sched.h>
>>>   #include<linux/slab.h>
>>> +#include<net/net_namespace.h>
>>>   #include "idmap.h"
>>>   #include "nfsd.h"
>>>
>>> @@ -466,20 +467,20 @@ nfsd_idmap_init(void)
>>>   {
>>>   	int rv;
>>>
>>> -	rv = cache_register(&idtoname_cache);
>>> +	rv = cache_register_net(&idtoname_cache,&init_net);
>>>   	if (rv)
>>>   		return rv;
>>> -	rv = cache_register(&nametoid_cache);
>>> +	rv = cache_register_net(&nametoid_cache,&init_net);
>>>   	if (rv)
>>> -		cache_unregister(&idtoname_cache);
>>> +		cache_unregister_net(&idtoname_cache,&init_net);
>>>   	return rv;
>>>   }
>>>
>>>   void
>>>   nfsd_idmap_shutdown(void)
>>>   {
>>> -	cache_unregister(&idtoname_cache);
>>> -	cache_unregister(&nametoid_cache);
>>> +	cache_unregister_net(&idtoname_cache,&init_net);
>>> +	cache_unregister_net(&nametoid_cache,&init_net);
>>>   }
>>>
>>>   static int
>>>


-- 
Best regards,
Stanislav Kinsbursky
