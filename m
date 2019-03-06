Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEBACC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 17:39:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFD10206DD
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 17:39:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=tycho.nsa.gov header.i=@tycho.nsa.gov header.b="MuyCcDZ+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726180AbfCFRjK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 12:39:10 -0500
Received: from upbd19pa07.eemsg.mail.mil ([214.24.27.82]:53958 "EHLO
        upbd19pa07.eemsg.mail.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726997AbfCFRjK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 12:39:10 -0500
X-Greylist: delayed 632 seconds by postgrey-1.27 at vger.kernel.org; Wed, 06 Mar 2019 12:39:08 EST
X-EEMSG-check-017: 205185724|UPBD19PA07_EEMSG_MP7.csd.disa.mil
Received: from emsm-gh1-uea11.ncsc.mil ([214.29.60.3])
  by upbd19pa07.eemsg.mail.mil with ESMTP/TLS/DHE-RSA-AES256-SHA256; 06 Mar 2019 17:28:33 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=tycho.nsa.gov; i=@tycho.nsa.gov; q=dns/txt;
  s=tycho.nsa.gov; t=1551893314; x=1583429314;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=sRWxWkUSdr7WLQ4xfvQFQjZ5pM1ixxk4c/P7btyZpzs=;
  b=MuyCcDZ+b9vQcv9Rl2POpSry8kQR88ncgFyHCJXpcrnodbG1Fpugnil3
   JX74epFekAiVm9nCrjX3Z38WHHFLzqPRvpgjcBYdQ4Y/TFtIvBGnhbDlC
   Pk1bZfjHaKi2mA2ucu3Z3rSjeOk36NMvzUdMeOHtDpxW82RE9pS1wxCNA
   5835VRsttFEpy0N4AU2hDep27ltCiqdGwVHqwJd36/2dO0e2purjA2Uh+
   kJZ0A1wPFyNQ45F48rYvePh67Fva7figew1rwMQY6yVX1rmDHXLubesVA
   X5BDZkAJcU95K0JpUCv7SzDoET7PTXk2nXFbECbGIofYg6biX/P1ZNqz9
   w==;
X-IronPort-AV: E=Sophos;i="5.58,448,1544486400"; 
   d="scan'208";a="24707066"
IronPort-PHdr: =?us-ascii?q?9a23=3Alf5llhfhB/xWERwNo8d4KMtYlGMj4u6mDksu8p?=
 =?us-ascii?q?Mizoh2WeGdxc27ZhGN2/xhgRfzUJnB7Loc0qyK6vimATVIyK3CmUhKSIZLWR?=
 =?us-ascii?q?4BhJdetC0bK+nBN3fGKuX3ZTcxBsVIWQwt1Xi6NU9IBJS2PAWK8TW94jEIBx?=
 =?us-ascii?q?rwKxd+KPjrFY7OlcS30P2594HObwlSizexfK9+IA+qoQnMq8IbnZZsJqEtxx?=
 =?us-ascii?q?XTv3BGYf5WxWRmJVKSmxbz+MK994N9/ipTpvws6ddOXb31cKokQ7NYCi8mM3?=
 =?us-ascii?q?0u683wqRbDVwqP6WACXWgQjxFFHhLK7BD+Xpf2ryv6qu9w0zSUMMHqUbw5Xy?=
 =?us-ascii?q?mp4rx1QxH0ligIKz858HnWisNuiqJbvAmhrAF7z4LNfY2ZKOZycqbbcNwUX2?=
 =?us-ascii?q?pBWttaWTJHDI2ycoADC/MNMOhcooX4oVYFsBmwChS2BO731zFGmHH206053e?=
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
 =?us-ascii?q?g5hPKO8RkPiKnZEqhC0w=3D=3D?=
X-IPAS-Result: =?us-ascii?q?A2BFAQCmAoBc/wHyM5BkGwEBAQEDAQEBBwMBAQGBZYFmK?=
 =?us-ascii?q?miBA4QvlDEBAQEBAQEGgQgIJXyIQIlVhw0wCAGEQAKEMSI4EgEBAwEBAQIBA?=
 =?us-ascii?q?wIBbBwMgjopAYJnAQUjFUEQCxgCAiYCAlcGDQgBAYJfPwGBaA0PqxiBL4VEh?=
 =?us-ascii?q?GAFgQskiykXeIEHgREnDIIqNYMeAoRrglcCkTU7kh8Jh0mLMQYZky8tkCGOV?=
 =?us-ascii?q?yGBVisIAhgIIQ+DKII/gziKcSEDgTUBAY0NAQE?=
Received: from tarius.tycho.ncsc.mil ([144.51.242.1])
  by emsm-gh1-uea11.NCSC.MIL with ESMTP; 06 Mar 2019 17:28:32 +0000
Received: from moss-pluto.infosec.tycho.ncsc.mil (moss-pluto [192.168.25.131])
        by tarius.tycho.ncsc.mil (8.14.4/8.14.4) with ESMTP id x26HSVZH018495;
        Wed, 6 Mar 2019 12:28:31 -0500
Subject: Re: [PATCH] security/selinux: fix SECURITY_LSM_NATIVE_LABELS on
 reused superblock
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>, selinux@vger.kernel.org,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
References: <20190305211758.GA27437@fieldses.org>
 <ea347670-ea52-3ab6-a786-aeebff40dd0e@tycho.nsa.gov>
 <20190306153435.GF2426@fieldses.org>
 <0d7ff441-fcfe-b68f-cdf9-44a923165a2c@tycho.nsa.gov>
 <20190306172559.GC3066@fieldses.org>
From:   Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <1b217037-9703-92a7-5dc7-f9dc817fbd15@tycho.nsa.gov>
Date:   Wed, 6 Mar 2019 12:28:49 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190306172559.GC3066@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 3/6/19 12:25 PM, J. Bruce Fields wrote:
> On Wed, Mar 06, 2019 at 11:49:36AM -0500, Stephen Smalley wrote:
>> On 3/6/19 10:34 AM, J. Bruce Fields wrote:
>>> On Wed, Mar 06, 2019 at 09:34:43AM -0500, Stephen Smalley wrote:
>>>> I've also have another script to test context= mount handling for
>>>> nfs since that should take precedence over native labels; it looks
>>>>   like that might be broken again:
>>>
>>> Thanks for the report, I'll take a look.  That's before or after
>>> applying this patch?  Assuming the former, do you have an idea how
>>> recent a regression it is?
>>
>> Now I'm having difficulty reproducing it entirely.  I thought on
>> stock Fedora 29 (4.20.x) I was seeing the actual underlying security
>> labels leaking through on files within the NFS mount despite using a
>> context= mount, while correctly seeing the context mount values with
>> your patch, but now I can't seem to repro.  It was this bug that
>> originally motivated Scott's commit that you are further fixing
>> IIUC,
>> https://github.com/SELinuxProject/selinux-kernel/issues/35
> 
> For what it's worth, I can't reproduce.  (If I mount with
> -overs=4.2,context=system_u:object_r:etc_t:s0 then ls -Z, I only see
> system_u:object_r:etc_t:s0.)

Yes, sorry for the noise.


