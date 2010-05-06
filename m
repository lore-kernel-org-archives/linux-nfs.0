From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/7] pnfs-submit api touch ups
Date: Thu, 06 May 2010 23:24:01 +0300
Message-ID: <4BE32561.9070607@panasas.com>
References: <4BE3166F.7060800@panasas.com> <o2o89c397151005061233vcaefdd27s4513be2b641348a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:50947 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756035Ab0EFUYM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 16:24:12 -0400
Received: by wwb39 with SMTP id 39so314455wwb.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 13:24:10 -0700 (PDT)
In-Reply-To: <o2o89c397151005061233vcaefdd27s4513be2b641348a2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-05-06 22:33, William A. (Andy) Adamson wrote:
> Looks good to me

Great.  I've release a 2.6.34-rc5 based version
and I'm currently rebasing and retesting over 2.6.34-rc6 (also w/ Zhang's fix)
and will release hopefully tomorrow.

Benny

> 
> --->Andy
> 
> On Thu, May 6, 2010 at 3:20 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> After rebasing everything on top of Andy and Fred patchsets I propose the following:
>>
>> [PATCH 1/2] SQUASHME: pnfs-submit: have initialize_mountpoint return status
>> [PATCH 2/2] SQUASHME: pnfs-submit: pass struct nfs_server * to getdeviceinfo
>> [PATCH 3/5] pnfs-post-submit: pass struct nfs_server * to getdevicelist
>> [PATCH 4/5] pnfs-post-submit: pass mntfh down the init_pnfs path
>> [PATCH 5/5] FIXME: pnfs-post-submit: per mount layout driver private data
>> [PATCH 6/6] SQUASHME: pnfs-block: convert APIs pnfs-post-submit
>> [PATCH 7/7] SQUASHME: pnfs-obj: convert APIs pnfs-post-submit
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

