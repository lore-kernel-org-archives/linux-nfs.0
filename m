Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay02.ispgateway.de ([80.67.31.40]:44966 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab2HONkM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2012 09:40:12 -0400
Message-ID: <502BA6B8.3090209@cape-horn-eng.com>
Date: Wed, 15 Aug 2012 15:40:08 +0200
From: Richard Ems <richard.ems@cape-horn-eng.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
References: <502A21A1.7020206@cape-horn-eng.com>   <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>   <20120814183512.GI23464@ZenIV.linux.org.uk>   <4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com>   <20120814151143.30fb9ca9@tlielax.poochiereds.net>   <502B8E9A.9010601@cape-horn-eng.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA93AB5CB@SACEXCMBX04-PRD.hq.netapp.com>  <502BA2A0.6000208@cape-horn-eng.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93AB714@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93AB714@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2012 03:38 PM, Myklebust, Trond wrote:
> On Wed, 2012-08-15 at 15:22 +0200, Richard Ems wrote:
>> On 08/15/2012 03:20 PM, Myklebust, Trond wrote:
>>>> (gdb) list *(nfs_lookup_revalidate+0x2d)
>>>> 0x59cd is in nfs_lookup_revalidate (/usr/src/debug/kernel-default-3.5.1/linux-3.5/fs/nfs/dir.c:1129).
>>>> 1124            struct dentry *parent;
>>>> 1125            struct nfs_fh *fhandle = NULL;
>>>> 1126            struct nfs_fattr *fattr = NULL;
>>>> 1127            int error;
>>>> 1128
>>>> 1129            if (nd->flags & LOOKUP_RCU)
>>>
>>> Bummer... We check if 'nd' is NULL everywhere except here...
>>>
>>> OK. Changing the above line to
>>>
>>> 	if (nd && (nd->flags & LOOKUP_RCU))
>>>
>>> will fix the problem.
>>
>> Ok, great !
>> Do you think this fix will go into 3.5.2 ?
> 
> I'll try to get it into stable. 3.6-rcX is unaffected by the bug due to
> recent VFS changes that have removed the "struct nameidata *" argument
> to nfs_lookup_revalidate.
> 

Ok, many thanks. I have found a couple of other accesses to nd with no
check for NULL at *nfs_atomic_lookup and nfs4_lookup_revalidate, but
don't know if those are relevant.

Thanks again,
Richard

-- 
Richard Ems       mail: Richard.Ems@Cape-Horn-Eng.com

Cape Horn Engineering S.L.
C/ Dr. J.J. Dómine 1, 5º piso
46011 Valencia
Tel : +34 96 3242923 / Fax 924
http://www.cape-horn-eng.com
