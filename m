Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:46434 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932715Ab2GBUWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 16:22:02 -0400
Received: by ghrr11 with SMTP id r11so4541387ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jul 2012 13:22:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com>
	<2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com>
Date: Mon, 2 Jul 2012 21:22:01 +0100
Message-ID: <CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com>
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ
 resulting in hang (BAD_STATEID)
From: "Charles 'Boyo" <charlesboyo@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 2, 2012 at 3:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> Usually we see this behavior because of a race between an OPEN with delegation and a delegation recall.  In this case, however, the client is actively returning a READ
> delegation, then proceeding to use it anyway.  I don't see the server's recall callback, though, and there are other indications that this trace is not complete. So it's hard
>  to be 100% confident.
>
The trace is not complete, it includes just enough information to
explain the problem.
However I can confirm the service did not send a recall callback, the
client returned the delegation of its own "free will".
>
> As far as I know, the EL6.2 client does not have support for recovering a single bad STATEID, which is why it is looping.  That support is available in mainline kernels 3.0
> and later.
>
> However, it seems to me that it is a bug for the client to continue using a delegation that it has returned.
>
Is it possible is a scheduling issue of some sort, where the READ
should have been sent ahead of the DELEGRETURN but somehow got mixed
up?
>
> You have already found one work-around: disable delegations on the NFS server.  Or you could mount with NFSv3.  Or, if feasible, your application could be modified to
> use fcntl() locking.
>
In my case, disabling delegation is the only feasible work-around.
NFSv3 creates new issues with identity mapping and the application is
closed-source.
With delegation disabled, what else do I stand to lose apart from some
client-side efficiencies? I have noticed that the client has resorted
to closing and re-opening commonly used files every few seconds -
probably an attempt to flush all data out to the server as soon as
possible. This hasn't caused me any grief, but I don't know what I'm
missing.

Regards,

Charles
