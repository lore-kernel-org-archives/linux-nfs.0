Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DCDFC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 16:58:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2074B20684
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 16:58:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=tycho.nsa.gov header.i=@tycho.nsa.gov header.b="cykOEkQh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726805AbfCFQ6r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 11:58:47 -0500
Received: from uphb19pa09.eemsg.mail.mil ([214.24.26.83]:49028 "EHLO
        USFB19PA12.eemsg.mail.mil" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726419AbfCFQ6r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 11:58:47 -0500
X-Greylist: delayed 559 seconds by postgrey-1.27 at vger.kernel.org; Wed, 06 Mar 2019 11:58:46 EST
X-EEMSG-check-017: 259919566|USFB19PA12_EEMSG_MP8.csd.disa.mil
Received: from emsm-gh1-uea10.ncsc.mil ([214.29.60.2])
  by USFB19PA12.eemsg.mail.mil with ESMTP/TLS/DHE-RSA-AES256-SHA256; 06 Mar 2019 16:49:25 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=tycho.nsa.gov; i=@tycho.nsa.gov; q=dns/txt;
  s=tycho.nsa.gov; t=1551890966; x=1583426966;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=u8x0qRX0tPASReU6+eEhFBH+ZHnul4f3qF3BFGW9vaE=;
  b=cykOEkQhCgFu7+gp3gpuqJf36rk8nNu80Pz48aLCG6mjPCWy8fNDv9+4
   qDkzVJC763iw5pE83unMviJ6jw/qbir1rM/livEqjjYuh3xeSvDrBrXlU
   iApdpGmb/2lgQL3SDAmWknTN7YN3wG7A1KAVpETLKC+6dVt4pP0an5jG7
   /12p+YvEEStH06UgBQ2slJRyhPE4Cpw3Y8/vb7gxdS5CjB3ipQD4bCUrp
   OKa9D5Na1AeGpAaVCmkaDvrWHZhEXw9XBmLr+3/6Il5FjO9qjj29yWrkE
   Fd/iyULJUZqegjSJvoH+pdrcPRDEMy8g5eG+IhwHvap1CsEyhbiszjBXJ
   g==;
X-IronPort-AV: E=Sophos;i="5.58,448,1544486400"; 
   d="scan'208";a="21194540"
IronPort-PHdr: =?us-ascii?q?9a23=3ARt1EexcSDdiMkrx8Fi8fjJTJlGMj4u6mDksu8p?=
 =?us-ascii?q?Mizoh2WeGdxc27ZhGN2/xhgRfzUJnB7Loc0qyK6vimATVIyK3CmUhKSIZLWR?=
 =?us-ascii?q?4BhJdetC0bK+nBN3fGKuX3ZTcxBsVIWQwt1Xi6NU9IBJS2PAWK8TW94jEIBx?=
 =?us-ascii?q?rwKxd+KPjrFY7OlcS30P2594HObwlSizexfK9+IA+qoQnMq8IbnZZsJqEtxx?=
 =?us-ascii?q?XTv3BGYf5WxWRmJVKSmxbz+MK994N9/ipTpvws6ddOXb31cKokQ7NYCi8mM3?=
 =?us-ascii?q?0u683wqRbDVwqP6WACXWgQjxFFHhLK7BD+Xpf2ryv6qu9w0zSUMMHqUbw5Xy?=
 =?us-ascii?q?mp4rx1QxH0ligIKz858HnWisNuiqJbvAmhrAF7z4LNfY2ZKOZycqbbcNwUX2?=
 =?us-ascii?q?pBWttaWTJHDI2ycoADC/MNMfhcooX4oVYFsBmwChS2BO731zFGmHH206053e?=
 =?us-ascii?q?ovHw7J0w4vEM4BvnnPsNX4Nr0fXfypwKTGzzjOae5d1zfn6IjPdxAsueyCXa?=
 =?us-ascii?q?5ufsrJyUkgCQXFhUiNp4zgJTyV0uANvHab7uF9Uu+vkHMoqxpqrzizxsYjlo?=
 =?us-ascii?q?nJhoUPxlDC7iV22pw5JdK/SE5leNOpFoZbuS+dN4tzWMwiQmdotT41yr0HpZ?=
 =?us-ascii?q?67fDUKx489yxHDbPyHdo6F6Q/gWuaJOTp0mX1odb2lixuy7ESs0PPwW8aq3F?=
 =?us-ascii?q?pQsyZIlMTHuGoX2BzJ8MeHT+Nw/kKm2TmSyQ/e8vpEIUUolarDLJ4h36Iwmo?=
 =?us-ascii?q?ITsUvdGi/2n137jLOMeUU+++io9v/nbq/6pp6cK4B0igb+Pr4omsOjGuQ3Lh?=
 =?us-ascii?q?ICX22a+eS4zLHj/Ev5T6tWjvAuj6XUv5/XKd4bq6KkGQNZzIku5wilAzu7yN?=
 =?us-ascii?q?gYmGMILFNBeBKJlYjpPFTOLejjDfiimFShiytrxvDaMb3hBZXBNH7DkKz7cr?=
 =?us-ascii?q?pn5E5czxQzwchF551IErEBPO7zWkjpudPDAB85MhK7w+L6B9VmzY4eV2OPDb?=
 =?us-ascii?q?GdMKzPql+H+PkvL/OLZI8Ptzb3M+Il6OL2jX8lhV8derGk3YMNZ3ClGvRrOF?=
 =?us-ascii?q?2ZbmDxgtcFCGsKuw0+TOvwiFKcSzJce3GyX6ck7DEhFI2mFZvDRpyqgLGZwi?=
 =?us-ascii?q?i7BodZZnpHClCXCnrob5+LW+0NaCKJOs9hliYLWqS/RIM70hGurgD6waJ9Lu?=
 =?us-ascii?q?XI4i0YqY7j1N9t6u3Iix4y8T10D8KA02CCVGx0gGwISCEs3Kxlokxy1E2D0a?=
 =?us-ascii?q?5mjPxcD9BT4OlJUggiP57G0+N6E8zyWh7GftqRU1amR8+pADExTt0vzd4DeF?=
 =?us-ascii?q?x9FMu/gRDDxSWqH6UZmKCMBJwx6qjcxWT+J95hy3ba06ksl10mQspJNW27ia?=
 =?us-ascii?q?9z7g7TB4DSk0iCiaaqeroT3DTX+GeA02WOpkdYXxB0UanfWnAffETW/pzF4R?=
 =?us-ascii?q?aIbfnmI646OQYJ58+PLqdRIJW9h1tHSfPvI/zQYm+1l3y9HlCP3LzaP6TwfG?=
 =?us-ascii?q?BI5znQEEgJlUgo+H+CMQUvTnO6r3n2EC1lFVWpZVjlt+Z5tiXoHQcP0wiWYh?=
 =?us-ascii?q?g5hPKO8RkPiKnZEqlC0w=3D=3D?=
X-IPAS-Result: =?us-ascii?q?A2AlAAA4+X9c/wHyM5BkGwEBAQEDAQEBBwMBAQGBUwQBA?=
 =?us-ascii?q?QELAYFlKmiBAyeECJQxAQEBAQEBBoEILXyIQIlVhRKBezAIAYRAAoQxIjYHD?=
 =?us-ascii?q?QEBAwEBAQIBAwIBbBwMgjopAYJmAQEBAQIBIwQRQRALFQMCAiYCAlcGDQYCA?=
 =?us-ascii?q?QGCXz8BgWgFCA+rEXwzhUSEYAWBCyQBiygXeIEHgREngjY1gx4CgSohgyCCV?=
 =?us-ascii?q?wKRNTuSHwmHSYsxBhmTLy2QIY5HDiOBVisIAhgIIQ+DJ4JAgziKcSEDMIEFA?=
 =?us-ascii?q?QGKQIJNAQE?=
Received: from tarius.tycho.ncsc.mil ([144.51.242.1])
  by EMSM-GH1-UEA10.NCSC.MIL with ESMTP; 06 Mar 2019 16:49:23 +0000
Received: from moss-pluto.infosec.tycho.ncsc.mil (moss-pluto [192.168.25.131])
        by tarius.tycho.ncsc.mil (8.14.4/8.14.4) with ESMTP id x26GlXbS005469;
        Wed, 6 Mar 2019 11:47:33 -0500
Subject: Re: [PATCH] security/selinux: fix SECURITY_LSM_NATIVE_LABELS on
 reused superblock
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>, selinux@vger.kernel.org,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
References: <20190305211758.GA27437@fieldses.org>
 <ea347670-ea52-3ab6-a786-aeebff40dd0e@tycho.nsa.gov>
 <20190306153435.GF2426@fieldses.org>
From:   Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <0d7ff441-fcfe-b68f-cdf9-44a923165a2c@tycho.nsa.gov>
Date:   Wed, 6 Mar 2019 11:49:36 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190306153435.GF2426@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 3/6/19 10:34 AM, J. Bruce Fields wrote:
> On Wed, Mar 06, 2019 at 09:34:43AM -0500, Stephen Smalley wrote:
>> On 3/5/19 4:17 PM, J. Bruce Fields wrote:
>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>
>>> In the case when we're reusing a superblock, selinux_sb_clone_mnt_opts()
>>> fails to set set_kern_flags, with the result that
>>> nfs_clone_sb_security() incorrectly clears NFS_CAP_SECURITY_LABEL.
>>>
>>> The result is that if you mount the same NFS filesystem twice, NFS
>>> security labels are turned off, even if they would work fine if you
>>> mounted the filesystem only once.
>>>
>>> ("fixes" may be not exactly the right tag, it may be more like
>>> "fixed-other-cases-but-missed-this-one".)
>>>
>>> Cc: Scott Mayhew <smayhew@redhat.com>
>>> Cc: stable@vger.kernel.org
>>> Fixes: 0b4d3452b8b4 "security/selinux: allow security_sb_clone_mnt_opts..."
>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>
>> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>
>>
>> Do you have some tests you are using for the selinux nfs support?
> 
> No.  I'll ask around.  Trond or Anna, do either of you do any selinux
> testing?
> 
>> I have an open issue on the selinux-testsuite with an example script
>> for running the regular selinux tests on a NFS mount but it can't
>> fully succeed as noted there,
>> https://github.com/SELinuxProject/selinux-testsuite/issues/32
> 
> So if I just clone
> https://github.com/SELinuxProject/selinux-testsuite.git and filter out
> those known failures, would that be a good starting point?

Yes, although you might want to remove the inet_socket and sctp tests 
from tests/Makefile before running it over NFS; it looks like there are 
some interactions between NFS and labeled networking (netlabel and 
ipsec/xfrm) that require further test policy changes to permit.

> 
>> I've also have another script to test context= mount handling for
>> nfs since that should take precedence over native labels; it looks
>>   like that might be broken again:
> 
> Thanks for the report, I'll take a look.  That's before or after
> applying this patch?  Assuming the former, do you have an idea how
> recent a regression it is?

Now I'm having difficulty reproducing it entirely.  I thought on stock 
Fedora 29 (4.20.x) I was seeing the actual underlying security labels 
leaking through on files within the NFS mount despite using a context= 
mount, while correctly seeing the context mount values with your patch, 
but now I can't seem to repro.  It was this bug that originally 
motivated Scott's commit that you are further fixing IIUC,
https://github.com/SELinuxProject/selinux-kernel/issues/35

> 
> --b.
> 
>> #!/bin/sh
>> cat > /etc/exports <<EOF
>> /home localhost(rw,no_root_squash,security_label)
>> EOF
>> exportfs -a
>> systemctl start nfs-server
>> mkdir -p /mnt/home
>> mount -t nfs -o vers=4.0,context=system_u:object_r:etc_t:s0
>> localhost:/home /mnt/home
>> echo "Under NFSv4.0:"
>> ls -Za /mnt/home
>> touch /mnt/home/foo
>> ls -Z /mnt/home/foo
>> ls -Z /home/foo
>> rm /mnt/home/foo
>> umount /mnt/home
>> mount -t nfs -o vers=4.2,context=system_u:object_r:etc_t:s0
>> localhost:/home /mnt/home
>> echo "Under NFSv4.2:"
>> ls -Za /mnt/home
>> touch /mnt/home/foo
>> ls -Z /mnt/home/foo
>> ls -Z /home/foo
>> rm /home/foo
>> umount /mnt/home
>> rmdir /mnt/home
>> rm /etc/exports
>> exportfs -ua
>> systemctl stop nfs-server
>>
>>> ---
>>>   security/selinux/hooks.c | 5 ++++-
>>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
>>> index f0e36c3492ba..5e9304567233 100644
>>> --- a/security/selinux/hooks.c
>>> +++ b/security/selinux/hooks.c
>>> @@ -959,8 +959,11 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>>>   	BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
>>>   	/* if fs is reusing a sb, make sure that the contexts match */
>>> -	if (newsbsec->flags & SE_SBINITIALIZED)
>>> +	if (newsbsec->flags & SE_SBINITIALIZED) {
>>> +		if ((kern_flags & SECURITY_LSM_NATIVE_LABELS) && !set_context)
>>> +			*set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
>>>   		return selinux_cmp_sb_context(oldsb, newsb);
>>> +	}
>>>   	mutex_lock(&newsbsec->lock);
>>>

