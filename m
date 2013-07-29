Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f52.google.com ([209.85.212.52]:37914 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787Ab3G2PnY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jul 2013 11:43:24 -0400
Received: by mail-vb0-f52.google.com with SMTP id f12so450651vbg.11
        for <linux-nfs@vger.kernel.org>; Mon, 29 Jul 2013 08:43:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130729145112.GA10489@redhat.com>
References: <51F39AE8.3090401@gmx.de>
	<20130727170051.GA31447@redhat.com>
	<51F5381D.1080904@gmx.de>
	<20130728175828.GA15020@redhat.com>
	<20130729062905.GA28282@paralelels.com>
	<20130729131031.GA6157@redhat.com>
	<20130729142749.GA27205@paralelels.com>
	<20130729145112.GA10489@redhat.com>
Date: Mon, 29 Jul 2013 19:43:22 +0400
Message-ID: <CANaxB-zfKTervWSOxZ5wj77RmLD_G7mJwFiuBmTp4TaoBOta9w@mail.gmail.com>
Subject: Re: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131
From: Andrey Vagin <avagin@openvz.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Vagin <avagin@parallels.com>,
        =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/7/29 Oleg Nesterov <oleg@redhat.com>:
> On 07/29, Andrew Vagin wrote:
>>
>> I don't have objections against this patch. All my tests work find.
>
> Great, thanks for confirmation. Can I translate this into your
> acked-by or tested-by if I send this patch?

Yes, you can.
Acked-by: Andrew Vagin <avagin@openvz.org>

>
> (there is another fix from Eric, it is not clear to me if I
>  should send it right now).
>
> Oleg.
>
