From: Peter Chacko <peterchacko35@gmail.com>
Subject: Re: NFS breaking under heavy load intermittently
Date: Mon, 2 Nov 2009 10:04:16 +0530
Message-ID: <1f808b4a0911012034s5aa681ffh4505a0c540c46022@mail.gmail.com>
References: <4AEE595E.8090203@sauce.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux RAID Mailing List <linux-nfs@vger.kernel.org>
To: Richard Scobie <richard-AknWbFEJEwOlP80pJB477g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f180.google.com ([209.85.223.180]:49246 "EHLO
	mail-iw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbZKBEeP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Nov 2009 23:34:15 -0500
Received: by iwn10 with SMTP id 10so3120697iwn.4
        for <linux-nfs@vger.kernel.org>; Sun, 01 Nov 2009 20:34:20 -0800 (PST)
In-Reply-To: <4AEE595E.8090203-AknWbFEJEwOlP80pJB477g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You can change the rsize and wsize, typically to 8k to avoid
unnecessary IP -fragmentation .

On Mon, Nov 2, 2009 at 9:30 AM, Richard Scobie <richard-AknWbFEJEwOlP80pJB477g@public.gmane.org> wr=
ote:
> Client: Core i7, 12GB Fedora 8 =A02.6.26.8-57.fc8 x86_64, NFS mount o=
ptions
> rsize=3D32768,wsize=3D32768,intr,hard,vers=3D3, Gigabit connected.
>
> Server: Core 2 Quad Xeon, 16GB Fedora 9 2.6.27.19-78.2.30.fc9.x86_64
>
> Under some heavy work loads where the client is pulling large files a=
nd all
> CPUs are maxed out, the NFS connection "disappears" - df shows no ent=
ry for
> the NFS mount and some minutes later it will reappear again.
>
> I am inclined to suspect the client, as similar workloads from other
> machines to the same server have no problem.
>
> Suspecting the onboard Realtek NIC, I replaced it with an Intel, but =
the
> problem still occurs.
>
> Can anyone tell me if there is likely to be a bug in these kernel ver=
sions
> that is contributing to this?
>
> Any debugging advice would be gratefully received; other than this in=
 dmesg:
>
> nfs: server flash not responding, still trying
> nfs: server flash not responding, still trying
> nfs: server flash OK
> nfs: server flash OK
>
>
> there is nothing in the kerenl logs.
>
> Regards,
>
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
