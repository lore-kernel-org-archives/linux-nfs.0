Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:43225 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab1FXCWz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 22:22:55 -0400
Message-ID: <4E03F4EA.5050206@panasas.com>
Date: Thu, 23 Jun 2011 19:22:34 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>
Subject: Re: autoload rpcsec_gss_krb5
References: <20110622213209.GA3010@fieldses.org> <20110623155947.GC8911@fieldses.org> <BANLkTikS+Y-V=f3Pm8AF-AUoeYVo==4SzA@mail.gmail.com> <20110623201117.GB12357@fieldses.org> <20110623203012.GD12357@fieldses.org>
In-Reply-To: <20110623203012.GD12357@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/23/2011 01:30 PM, J. Bruce Fields wrote:
> On Thu, Jun 23, 2011 at 04:11:17PM -0400, J. Bruce Fields wrote:
>> On Thu, Jun 23, 2011 at 10:06:14PM +0200, Tigran Mkrtchyan wrote:
>>> I recall a discussion at connectaton 2010, where Peter Staubach from
>>> RedHat ( at that time )
>>> requested a way to disable pNFS without rebuilding the kernel.
>>>
>>> Probably that's why autoload is not implemented.
>>
>> Well, autoload *is* implemented, you just have to add an alias command
>> to modprobe.conf before it'll work.
>>
>> And if we embed the alias in the module instead, it will still be
>> possible to disable autloading by adding a "backlist <modulename>" to
>> modproble.conf.
>>
>> So I don't *think* that's the issue, unless I've missed something.
> 
> So can we just do this?  (Untested.)
> 
> --b.
> 
> commit 8b3065071b5469c428d70052c80f1df3cb398da6
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Jun 23 16:15:39 2011 -0400
> 
>     pnfs: simplify pnfs files module autoloading
>     
>     Embed the necessary alias into the module rather than waiting for
>     someone to add it to /etc/modprobe.conf
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 4269088..eb65f82 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -896,5 +896,7 @@ static void __exit nfs4filelayout_exit(void)
>  	pnfs_unregister_layoutdriver(&filelayout_type);
>  }
>  
> +MODULE_ALIAS("nfs-layouttype4-1");
> +
>  module_init(nfs4filelayout_init);
>  module_exit(nfs4filelayout_exit);
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 70272d5..dd6a453 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1065,5 +1065,7 @@ objlayout_exit(void)
 	       __func__);
 }
 
+MODULE_ALIAS("nfs-layouttype4-2");
+
 module_init(objlayout_init);
 module_exit(objlayout_exit);
---

nfs-layouttype4-1
nfs-layouttype4-2
...

Can we use a name here or it must be the number?

Thanks
Boaz

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
