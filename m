Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm11.bullet.mail.sp2.yahoo.com ([98.139.91.81]:24779 "HELO
	nm11.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752430Ab1ATGz1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 01:55:27 -0500
Message-ID: <164222.10285.qm@web111725.mail.gq1.yahoo.com>
References: <574433.84174.qm@web111710.mail.gq1.yahoo.com> <AANLkTim8r-MWCytdP7QmhBoe9iM+39sZwmqaEzj64NtS@mail.gmail.com> <146716.56866.qm@web111715.mail.gq1.yahoo.com> <AANLkTi=jXihAzfaCz3BLum97hxsoimC6rSEEv5Uyf3y7@mail.gmail.com>
Date: Wed, 19 Jan 2011 22:55:25 -0800 (PST)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: high traffic because of loggig
To: Lyle Seaman <lyleseaman@gmail.com>
Cc: nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <AANLkTi=jXihAzfaCz3BLum97hxsoimC6rSEEv5Uyf3y7@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>Try sticking one of these in there before the redirection:  ' | dd bs=8m '
 
Thanks,
// Naderan *Mahmood;



----- Original Message ----
From: Lyle Seaman <lyleseaman@gmail.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Sent: Thu, January 20, 2011 1:30:09 AM
Subject: Re: high traffic because of loggig

Try sticking one of these in there before the redirection:  ' | dd bs=8m '

On Wed, Jan 19, 2011 at 2:58 PM, Mahmood Naderan <nt_mahmood@yahoo.com> wrote:
>>It would depend on the application.
>
> It uses the standard output redirection '>' which I think every 5KB writes the
> output. Can I increase that threshold?
>
> // Naderan *Mahmood;
>
>
>
> ----- Original Message ----
> From: Another Sillyname <anothersname@googlemail.com>
> To: Mahmood Naderan <nt_mahmood@yahoo.com>
> Sent: Wed, January 19, 2011 10:05:07 PM
> Subject: Re: high traffic because of loggig
>
> On 19 January 2011 18:09, Mahmood Naderan <nt_mahmood@yahoo.com> wrote:
>> Hi,
>> In my cluster that /home is shared (from a server and some workers). The
>>problem
>> is when I run my job that has some huge log data, the disk access as well as
>> network traffic is very high. I want to know is there any way so
>> that the worker writes the log locally and at the end, that log is copied 
from
>> worker's internal hdd to server's hdd (/home)?
>>
>> Hope that I clearly stated the problem.
>> Thanks,
>> // Naderan *Mahmood;
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> It would depend on the application.
>
> If the application doesn't have options to choose the path for the log
> files you could set up a symbolic link to the path back to the local
> drive.
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



      
