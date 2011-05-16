Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61299 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab1EPOrp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 10:47:45 -0400
Received: by iyb14 with SMTP id 14so3788367iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 07:47:45 -0700 (PDT)
In-Reply-To: <4DD13350.1000207@RedHat.com>
References: <BANLkTinSoHVQH1meHMwCtxEp8Mku1gJv0Q@mail.gmail.com>
	<4DD13350.1000207@RedHat.com>
Date: Mon, 16 May 2011 16:47:44 +0200
Message-ID: <BANLkTim0_AnmgVaqf9NTV_GwCCrcRToJxQ@mail.gmail.com>
Subject: Re: [PATCH] rpc.idmapd dies with 'I/O possible'
From: Luca Giuzzi <luca.giuzzi@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 16, 2011 at 4:23 PM, Steve Dickson <SteveD@redhat.com> wrote:

> I just updated the bz with these questions, but we can have the
> conversation here...
>
> I'm just a bit concerned by the fact that there are
> a couple of places that sets F_SETSIG and then sets F_NOTIFY,
> so does that mean those places are potential race cases as
> well?
>
where does this happen? There are 3 places where I have seen these fcntl's.
The first three are:
1. in idmapd.c, at nfsopen()
2. in gssd_proc.c at process_clnt_dir()
3. in gssd_main_loop.c at topdirs_add_entry()
In all of these cases, the pattern is to set the SETSIG to something useful, and
then enable NOTIFY, though; thus they should not determine a race.
[there is also a fourth one in idmapd, where the signals are actually
initialized (lines 357-360); however, in the case of failure of the
first SETSIG the daemon does not start]

> Also, after you applied this patch, did the problem go away?

I honestly don't know: the problem seems to have disappeared, in the
sense that the patched daemon has not died. However, before it
occurred with quite a random
pattern (usually, once per day per machine, but it really depended) so
I cannot be sure (it might be it was also related to the overall load
- unfortunately I do not
have the proper statistics).


best,
 lg
