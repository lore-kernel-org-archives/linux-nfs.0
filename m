Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:46748 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525Ab2H1Qbb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 12:31:31 -0400
Received: by wibhr14 with SMTP id hr14so5010181wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 09:31:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFtxgO6FNuqOcvXvu_Y_-NmojpyC2GHiX5rpMQuY4u4zYYbwWg@mail.gmail.com>
References: <CAFtxgO5if9qDf9Lex+=hPjrQBgy9ZOnQDr+CWvGY2U7dpC3dOQ@mail.gmail.com>
	<CAHVgHyX9aDLjYH0QwUCjx8tXwjsdm=MqH2GPY_68P6XHkYGhVQ@mail.gmail.com>
	<CAFtxgO6FNuqOcvXvu_Y_-NmojpyC2GHiX5rpMQuY4u4zYYbwWg@mail.gmail.com>
Date: Tue, 28 Aug 2012 12:31:30 -0400
Message-ID: <CAHVgHyXBu5Ocb+MiAjbL_tn3CVx19+usbnDr1R-n4S9PCjK78A@mail.gmail.com>
Subject: Re: [NFS v4.1] State manager error 22?
From: Andy Adamson <androsadamson@gmail.com>
To: Jeff Garzik <jeff@garzik.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 28, 2012 at 12:11 PM, Jeff Garzik <jeff@garzik.org> wrote:
> On Tue, Aug 28, 2012 at 12:06 PM, Andy Adamson <androsadamson@gmail.com> wrote:
>> Which kernel?
>
> Sorry!  I had highlighted the kernel version for pasting, then forgot
> to paste it:
>
>      3.5.2-3.fc17.i686

OK

>
>> Note that there are multiple checks on the successful CREATE_SESSION
>> response that will trigger the client to reject the CREATE_SESSION
>> response with -EINVAL.
>>
>> For example, if the recv maximum response size is greater than the
>> sent maximum response size, or if the recv maximum number of
>> operations is less than the sent maximum number of operations.....
>
> Would this be nfs4_reclaim_lease(), nfs4_check_lease(),
> nfs4_reset_session() or nfs4_bind_conn_to_session()?

nfs4_verify_fore_channel_attrs and nfs4_verify_back_channel_attrs was
what I was looking at. I would also check the server responses (and
the client reaction!) against rfc5661.

Have you turned on client debugging to /var/log/messages?  This turns
it all on which for a mount failure is ok.

# rpcdebug -v -m nfs -s all

-->Andy


>
> Trying to narrow down where the check fails, and there's a lot of code
> that seemingly might cause a failure there.
>
> Thanks,
>
>      Jeff
