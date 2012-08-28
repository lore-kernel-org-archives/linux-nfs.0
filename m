Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:39624 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751110Ab2H1RJQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 13:09:16 -0400
Received: by lagy9 with SMTP id y9so3444240lag.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 10:09:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHVgHyXBu5Ocb+MiAjbL_tn3CVx19+usbnDr1R-n4S9PCjK78A@mail.gmail.com>
References: <CAFtxgO5if9qDf9Lex+=hPjrQBgy9ZOnQDr+CWvGY2U7dpC3dOQ@mail.gmail.com>
	<CAHVgHyX9aDLjYH0QwUCjx8tXwjsdm=MqH2GPY_68P6XHkYGhVQ@mail.gmail.com>
	<CAFtxgO6FNuqOcvXvu_Y_-NmojpyC2GHiX5rpMQuY4u4zYYbwWg@mail.gmail.com>
	<CAHVgHyXBu5Ocb+MiAjbL_tn3CVx19+usbnDr1R-n4S9PCjK78A@mail.gmail.com>
Date: Tue, 28 Aug 2012 13:09:14 -0400
Message-ID: <CAFtxgO7qM+FDMEMUOVe1Z+LcYHmtQAPUdxd1zeGqtpidFo1wfQ@mail.gmail.com>
Subject: Re: [NFS v4.1] State manager error 22?
From: Jeff Garzik <jeff@garzik.org>
To: Andy Adamson <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 28, 2012 at 12:31 PM, Andy Adamson <androsadamson@gmail.com> wrote:
> nfs4_verify_fore_channel_attrs and nfs4_verify_back_channel_attrs was
> what I was looking at. I would also check the server responses (and
> the client reaction!) against rfc5661.
>
> Have you turned on client debugging to /var/log/messages?  This turns
> it all on which for a mount failure is ok.
>
> # rpcdebug -v -m nfs -s all

Will give that a try.  But it looks like I need to rebuild with
CONFIG_NFS_DEBUG...

     Jeff
