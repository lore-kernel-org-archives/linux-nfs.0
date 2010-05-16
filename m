From: hce <webmail.hce@gmail.com>
Subject: Re: NFS cache
Date: Mon, 17 May 2010 09:54:12 +1000
Message-ID: <AANLkTilYaqsm-Yp-LKaB2H0lTxm6_YjKwEJ2AVEn4wJt@mail.gmail.com>
References: <AANLkTikZfdnCMm0TkEaVnN2kqVzMZ7CYmbe1YengmRMY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:35581 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab0EPXyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 19:54:15 -0400
Received: by pxi5 with SMTP id 5so2228155pxi.19
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 16:54:12 -0700 (PDT)
In-Reply-To: <AANLkTikZfdnCMm0TkEaVnN2kqVzMZ7CYmbe1YengmRMY-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 16, 2010 at 6:26 PM, hce <webmail.hce@gmail.com> wrote:
> Hi,
>
> I posted following message on list, but did not see it on list, sorry
> if it is duplicated.
>
> I have an application to use NFS over FUSE, if I keep typing "ls" in
> the same directory, the client NFS only sent GETATT, no more READDIR,
> all directory contents displayed on screen came from NFS cache. That
> caused many problems and I'd like to disable NFS client cache. But it
> did not work when I add "-o noac" option to mount.

I've just realised that the noac is only for NFS attribute cache, so
add "-o noac" only generates more getatt for up paths, the "readdir"
was still not called if I keep typing "ls" in the same directory.

Does NFS has another cache for directory structure as well? It seems
it displayed directory contents on the screen from cache as it did not
call readdir to FUSe.

> Also I don't want
> NFS GETATT retransmission during file copy. Appreciate your advice and
> sample examples for how to mount nfs to disable client cache and
> retransmission.
