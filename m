Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33292 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbbJMPCj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 11:02:39 -0400
Received: by igbkq10 with SMTP id kq10so92640630igb.0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 08:02:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151013143445.GE10632@dot.dmz.freshdot.net>
References: <20151013122128.GD10632@dot.dmz.freshdot.net>
	<CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
	<20151013143445.GE10632@dot.dmz.freshdot.net>
Date: Tue, 13 Oct 2015 11:02:38 -0400
Message-ID: <CAN-5tyFNor0HmY5xMM7EVfGtec8U2iUVk8942xzC6sAP4Yn4sA@mail.gmail.com>
Subject: Re: CAP(abilities) and NFS mounted storage
From: Olga Kornievskaia <aglo@umich.edu>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 10:34 AM, Sander Smeenk <ssmeenk@freshdot.net> wrote:
> Quoting Trond Myklebust (trond.myklebust@primarydata.com):
>
>> > I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
>> > not enough. I'd very much like to hear if it is possible for this to
>> > work on NFS like it does on local storage.
>> This will not work on NFS. The server, which enforces permissions, has
>> no way to know what capabilities your process has on the client.
>
> Thanks. I feared this answer. But i understand that the NFS-server cant
> know if the process on the NFS-client has CAP_DAC_READ_SEARCH
> capabilities set.
>
> Would setfsuid() help anything in this case? Or is it just a big no-go?
>

Are you looking for something like labeled NFS that supports
capabilities? I think Redhat7 has SElinux labeled NFS support.

> -Sndr.
> --
> | Daylight savings time - why are they saving it and where do they keep it?
> | 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
