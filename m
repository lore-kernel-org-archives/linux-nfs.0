From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/7] pnfs-submit api touch ups
Date: Thu, 6 May 2010 15:33:03 -0400
Message-ID: <o2o89c397151005061233vcaefdd27s4513be2b641348a2@mail.gmail.com>
References: <4BE3166F.7060800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39398 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676Ab0EFTdG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:33:06 -0400
Received: by gyg13 with SMTP id 13so217812gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 12:33:04 -0700 (PDT)
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me

--->Andy

On Thu, May 6, 2010 at 3:20 PM, Benny Halevy <bhalevy@panasas.com> wrot=
e:
> After rebasing everything on top of Andy and Fred patchsets I propose=
 the following:
>
> [PATCH 1/2] SQUASHME: pnfs-submit: have initialize_mountpoint return =
status
> [PATCH 2/2] SQUASHME: pnfs-submit: pass struct nfs_server * to getdev=
iceinfo
> [PATCH 3/5] pnfs-post-submit: pass struct nfs_server * to getdeviceli=
st
> [PATCH 4/5] pnfs-post-submit: pass mntfh down the init_pnfs path
> [PATCH 5/5] FIXME: pnfs-post-submit: per mount layout driver private =
data
> [PATCH 6/6] SQUASHME: pnfs-block: convert APIs pnfs-post-submit
> [PATCH 7/7] SQUASHME: pnfs-obj: convert APIs pnfs-post-submit
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
