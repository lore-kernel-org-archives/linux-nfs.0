Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37594 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab2ITSJR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Sep 2012 14:09:17 -0400
Received: by wibhr14 with SMTP id hr14so1053455wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2012 11:09:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXagDP6TPO+7pCCcUyac+ViPgKVThTsuehHNi_xwTpnGiQ@mail.gmail.com>
References: <CAJ75kXZuM_p3qknD4RgdjLLWd393u02S5FKQyu3Q8y8NwmfiVw@mail.gmail.com>
	<CAJ75kXagDP6TPO+7pCCcUyac+ViPgKVThTsuehHNi_xwTpnGiQ@mail.gmail.com>
Date: Thu, 20 Sep 2012 14:09:14 -0400
Message-ID: <CAHVgHyW=dia9kktHX-hyVbLGwDX7FpmmqsV+7qvyaT8QofBuQQ@mail.gmail.com>
Subject: Re: unhandled error -10026
From: Andy Adamson <androsadamson@gmail.com>
To: William Dauchy <wdauchy@gmail.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>, R.Eggermont@tudelft.nl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 20, 2012 at 10:34 AM, William Dauchy <wdauchy@gmail.com> wrote:
> On Tue, Sep 18, 2012 at 11:49 AM, William Dauchy <wdauchy@gmail.com> wrote:
>> I'm getting a trace following an unhandled error on a linux nfs client
>> 3.4.7 x86_64.
>> NFS: nfs4_reclaim_open_state: unhandled error -10026. Zeroing state
>
> For the moment I don't know if the error is coming from a bad server
> implementation or if it's on client side. Should I assume that this an
> error that should never hit the client?

Do you have a tcpdump trace you could share?

-->Andy

>
> Regards,
> --
> William
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
