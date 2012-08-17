Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:49332 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757463Ab2HQKuo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2012 06:50:44 -0400
Received: by obbuo13 with SMTP id uo13so5104841obb.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2012 03:50:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502E1C38.2060104@compcenter.org>
References: <502B55A3.3030007@compcenter.org>
	<502E1C38.2060104@compcenter.org>
Date: Fri, 17 Aug 2012 11:50:43 +0100
Message-ID: <CAA4Z2ZQR4RVCEzct2AH4yBy=oGkw78M=Gc8pOWC5C0vGbSy-Xg@mail.gmail.com>
Subject: Re: Randomly inaccessible files through NFS
From: Adrien Kunysz <adk@acunu.com>
To: "Denis V. Nagorny" <dvnagorny@compcenter.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I would try to tcpdump all NFS traffic starting when the client is in
the "stable" state (including the MOUNT call). Once it's in the
"unstable" state, I would stop the capture then try to figure out
exactly at what point it switched from "stable" to "unstable" (maybe
figure out when exactly the NFS4ERR_EXPIRED start to happen) and track
it down to a specific NFS pattern.

I don't know much about NFS really so I cannot be more specific. Yes,
this probably requires lot of storage to capture all the traffic and
lot of time to analyse the captured data.

On Fri, Aug 17, 2012 at 11:26 AM, Denis V. Nagorny
<dvnagorny@compcenter.org> wrote:
> 15.08.2012 11:54, Denis V. Nagorny пишет:
>
>> Hello,
>>
>> Using Scientific Linux 6.1 (I think it's equal to RH EL 6.1) we met the
>> strange issue.  Several last months we have problem. After one or two days
>> of successful work, files on nfs server begins to be randomly unacessible.
>> I doesn't mean that files becames hidden or something like this. It means
>> that attempts to open some random files may be unsuccessful. Usually restart
>> of nfs server makes situation better but for several days only. There are no
>> any messages about errors in logs on server and clients machines. Can
>> anybody point me how can I try to understand what happens at least. Sorry
>> for my english.
>>
>> Denis.
>
>
> Hello again,
>
> I've made some additional experiments. It looks like nfs clients can be in
> one of two states: "quite stable" and "quite unstable". Clients are usually
> stable but after some heavy job with a lot of I/O with NFS server clients
> become "quite unstable" and fails even with single file operations with NFS
> server. In this state I can't unmount NFS shares and so on.  I've tried to
> analyse with wireshark and found that in unstable state there are a lot of
> NFS4ERR_EXPIRED answers from NFS server.  In one of experiments I've changed
> NICs in both machines involved - result the same. So I'm still looking for
> the ways to understand the problem.
> Can anybody give me any advices?
>
> Denis
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
