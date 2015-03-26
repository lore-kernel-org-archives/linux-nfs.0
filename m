Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930AbbCZRIh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 13:08:37 -0400
Message-ID: <55143D14.4020701@RedHat.com>
Date: Thu, 26 Mar 2015 13:08:36 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Abhijit Pal <21.abhijit@gmail.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: nfs.5: Add addr mount option for all nfs versions
References: <CAL8eLxVyJYiSmVL1FP6eFNmMQCQZRHO+rYP5Wvv9cyZ+DU_jiQ@mail.gmail.com> <CAL8eLxW7_B=_B-h2Ph_dgWf4nmcNmG8DZoi7BqPYc3y95EcMTg@mail.gmail.com>
In-Reply-To: <CAL8eLxW7_B=_B-h2Ph_dgWf4nmcNmG8DZoi7BqPYc3y95EcMTg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/24/2015 08:19 AM, Abhijit Pal wrote:
> Hello linux-nfs team,
> 
> Thank you for giving your attention and time to my query.
> 
> Wanted to get an insight about a problem regarding nfs mount using the
> system call mount(2) which was reported by one of the user in
> "StackOverflow".
> 
> The URL for the problem statement and the accepted solution is:
> http://stackoverflow.com/questions/28350912/nfs-mount-system-call-in-linux
> 
> After going through the kernel code(v 3.18.6), I have posted an answer
> which worked for the user and was accepted. Was thinking if you can
> guide me if the accepted solution is indeed a bug or not. And if the
> solution is acceptable would request you to kindly let me know the
> process, so that I can send a patch for updating the nfs(5) man page.
> 
Mail the patch to this list following these guidelines 
   https://www.kernel.org/doc/Documentation/SubmittingPatches

steved.

