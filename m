Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34847 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab2FYJEi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 05:04:38 -0400
Received: by pbbrp8 with SMTP id rp8so6278904pbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2012 02:04:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120625074306.48500@gmx.net>
References: <20120625074306.48500@gmx.net>
Date: Mon, 25 Jun 2012 12:04:37 +0300
Message-ID: <CABpMAyJi7wGB5Da_3dMXfK0wnDfAeWbpsUB=j0rpkOv7GfPb5g@mail.gmail.com>
Subject: Re: LAYOUTCOMMIT/LAYOUTRETURN
From: Idan Kedar <idank@tonian.com>
To: Johannes Schild <JSchild@gmx.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 25, 2012 at 10:43 AM, Johannes Schild <JSchild@gmx.de> wrote:
> Hi Guys,
>
> i have another question on pNFS. I looked at my Wireshark protocols, while i used the FILE-Layout, and i wondered why i have no LAYOUTCOMMIT/LAYOUTRETURN statements in my protocols.
> I transfered one file to my storage server (NETAPP Simulator 8.1 C-Mode) and i only got a LAYOUTGET.
>
> cat /proc/self/mountstats | grep LAYOUT says:
> nfsv4: bm0=0xfafe8fff,bml=0x60fdfffe,acl=0x3,sessions,pnfs=LAYOUT_NFSV4_1_FILES
>    LAYOUTGET: 1 1 0 216 236 0 1 1
>  LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
>  LAYOUTRETURN: 0 0 0 0 0 0 0 0
>
>
> Is there any other way to verify that pnfs is used on client site?
>
>
> Thanks in advance
>
>
> Best Regards
>
> Johannes
>
>
>
> --
> Empfehlen Sie GMX DSL Ihren Freunden und Bekannten und wir
> belohnen Sie mit bis zu 50,- Euro! https://freundschaftswerbung.gmx.de
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

about layoutcommit:
http://tools.ietf.org/rfcmarkup?doc=5661#section-13.7

about layoutreturn:
http://tools.ietf.org/rfcmarkup?doc=5661#section-12.5.5.1

-- 
Idan Kedar
Tonian
