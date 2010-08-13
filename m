Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55971 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab0HMVdg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 17:33:36 -0400
Received: by wyb32 with SMTP id 32so3090807wyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 14:33:35 -0700 (PDT)
In-Reply-To: <0C88B758-1DE8-4CFB-9546-A30104009A12@oracle.com>
References: <AANLkTik_gAeTWhD_=zSUrqh2eYir=q4bK4cJ6UdGQ11M@mail.gmail.com> <0C88B758-1DE8-4CFB-9546-A30104009A12@oracle.com>
From: Rahul Nabar <rpnabar@gmail.com>
Date: Fri, 13 Aug 2010 16:33:15 -0500
Message-ID: <AANLkTimqTvgyvvjP2R12wsdpZRs10T+YAtUGw7u6pxWZ@mail.gmail.com>
Subject: Re: NFS and file locking for use with sqllite
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 4:15 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> It's really not clear what is meant by this vague warning.  Maybe you should ask for details from the sqlite development community.

Thanks Chuck! The warning seemed pretty vague to me as well. Just
thought I'd doublecheck if there was something obvious I was missing.
Thanks for your comments.

>
> You have two choices on Linux clients:  "lock" and "nolock".  They control whether file locks appear to other clients or not.  I assume >your applications cares about serialization with processes only on the same client where it is running.  Mount options almost certainly >do not matter in this case.
>

I do have locking enabled. I'm not using "nolock" as a option and I
have lockd daemon running.

-- 
Rahul
