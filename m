From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: Am I still the one to fix the NFS_FILE_SYNC problem
Date: Mon, 24 May 2010 09:14:18 -0400
Message-ID: <AANLkTilR7cJu1uCv60GrpFimqDWb0ogyvKVh1q0iW_6a@mail.gmail.com>
References: <4BF975A3.7090509@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f227.google.com ([209.85.217.227]:38951 "EHLO
	mail-gx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab0EXNOT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 09:14:19 -0400
Received: by gxk27 with SMTP id 27so620242gxk.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 06:14:18 -0700 (PDT)
In-Reply-To: <4BF975A3.7090509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Boaz

The last patch I sent in [PATCH 1/1] SQUASHME pnfs-submit: replace
layoutcommit_ctx with rpc_cred fixes the NFS_FILE_SYNC problem for
files. It replaces taking a reference on the open context with taking
a reference on the rpc_cred.

-->Andy
			=09

On Sun, May 23, 2010 at 2:36 PM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
>
> Andy, Benny are you waiting on me to fix the NFS_FILE_SYNC problem?
>
> I've been on a long holiday, but I can attempt a fix tomorrow if stil=
l
> needed?
>
> I was hoping someone else need that more urgently then me, since I al=
ready
> have a work around, for my testing ;-)
>
> Boaz
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
