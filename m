Return-Path: <SRS0=5tQo=CJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C989C433E6
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Aug 2020 15:00:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6BF37207EA
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Aug 2020 15:00:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="LTeZUhf7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728152AbgHaPAT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Aug 2020 11:00:19 -0400
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:31837 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726144AbgHaPAS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2020 11:00:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1598886016;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=woPAVn2W2urwAJMlitBBSXbUyw+668GYRJLJriE6CcQ=;
        b=LTeZUhf7CpNfPik1zrfG1tSuQrAQV5Vjj5EVTXyJj/3OUBHIH8Cp7a5qoVoj2oAj1+F8za
        Bm3MR0U2ZHliwO86k2tRkhZIEwt5igj0nU5QoUiAJ9DPKihDrGrjohhmG5Modk16oY/6FU
        A20UyFF4vSC+WLwW8OlLHzmLyp3Hk6A=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-379-jELEWwZVN6W2o2xbXkpcsw-1; Mon, 31 Aug 2020 11:00:14 -0400
X-MC-Unique: jELEWwZVN6W2o2xbXkpcsw-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 4637010ABDA3
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2020 15:00:12 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-190.phx2.redhat.com [10.3.113.190])
        by smtp.corp.redhat.com (Postfix) with ESMTP id EF9FF5C3E0;
        Mon, 31 Aug 2020 15:00:11 +0000 (UTC)
Subject: Re: [PATCH] nfs-iostat: divide by zero with fresh mount
To:     Kenneth D'souza <kdsouza@redhat.com>, linux-nfs@vger.kernel.org
References: <20200824150535.15224-1-kdsouza@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <2bb2d561-9a58-4552-41ae-24993b91f982@RedHat.com>
Date:   Mon, 31 Aug 2020 11:00:11 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.11.0
MIME-Version: 1.0
In-Reply-To: <20200824150535.15224-1-kdsouza@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 8/24/20 11:05 AM, Kenneth D'souza wrote:
> When an export is freshly mounted, /proc/self/mountstats displays age = 0.
> This causes nfs-iostat to divide by zero throwing an error.
> When we have age = 0, other stats are greater than 0, so we'll set age = 1 and
> print the relevant stats.
> 
> This will prevent a backtrace like this from occurring if nfsiostat is run.
> 
> nfsiostat -s 1
> Traceback (most recent call last):
>   File "/usr/sbin/nfsiostat", line 662, in <module>
>     iostat_command(prog)
>   File "/usr/sbin/nfsiostat", line 644, in iostat_command
>     print_iostat_summary(old_mountstats, mountstats, devices, sample_time, options)
>   File "/usr/sbin/nfsiostat", line 490, in print_iostat_summary
>     devicelist.sort(key=lambda x: stats[x].ops(time), reverse=True)
>   File "/usr/sbin/nfsiostat", line 490, in <lambda>
>     devicelist.sort(key=lambda x: stats[x].ops(time), reverse=True)
>   File "/usr/sbin/nfsiostat", line 383, in ops
>     return (sends / sample_time)
> ZeroDivisionError: float division by zero
> 
> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
Committed... (tag: nfs-utils-2-5-2-rc4)

steved.
> ---
>  tools/nfs-iostat/nfs-iostat.py | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index 5556f692..0c6c6dda 100755
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -383,6 +383,8 @@ class DeviceData:
>          sends = float(self.__rpc_data['rpcsends'])
>          if sample_time == 0:
>              sample_time = float(self.__nfs_data['age'])
> +        if sample_time == 0:
> +            sample_time = 1;
>          return (sends / sample_time)
>  
>      def display_iostats(self, sample_time, which):
> 

