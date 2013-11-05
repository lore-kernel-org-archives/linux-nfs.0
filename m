Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35562 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3KEGC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 01:02:28 -0500
Received: by mail-pd0-f177.google.com with SMTP id p10so7763160pdj.22
        for <linux-nfs@vger.kernel.org>; Mon, 04 Nov 2013 22:02:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5277C006.1060003@RedHat.com>
References: <CADtAWjC5PWixao_aPuqSiPxPSqhwN8PShQf7Jctua9aqzjc_YA@mail.gmail.com>
	<5277C006.1060003@RedHat.com>
Date: Tue, 5 Nov 2013 08:02:27 +0200
Message-ID: <CADtAWjDkM5TAqjJKF7bQOx2od1Qkc+pECAGMJBOjx7G8KuTinw@mail.gmail.com>
Subject: Re: rpc.idmapd plugin for sssd
From: Noam Meltzer <tsnoam@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 4, 2013 at 5:40 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
>
> On 03/11/13 06:50, Noam Meltzer wrote:
> > Hello,
> >
> > I was thinking of writing a plugin for rpc.idmapd which will retrieve
> > the required information from SSSD (https://fedorahosted.org/sssd/)
> What is the purpose of the plug in? And are you aware rpc.idmapd is
> only used on the server these days... the nfsidmap command is used
> by the client...
Actually I wasn't aware of it, good to know.
However, I was targeting the server side.
The purpose of this plugin is to allow the rpc.idmapd interact
directly with SSSD without going the extra layer of NSS/libc.



>
> >
> > Before doing so, I just wanted to make sure that no one here is aware
> > of an existing plugin?
> No, there is no plugins for rpc.idmapd....
>
> steved.
>
> >
> > Best regards,
> > Noam Meltzer
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
