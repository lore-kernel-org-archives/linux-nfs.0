From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] lockd
Date: Mon, 04 Oct 2004 15:25:51 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <4161A3BF.4020908@RedHat.com>
References: <41617958.2020406@RedHat.com> <1096912231.22446.60.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268568AbUJDTff@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1096912231.22446.60.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>



Trond Myklebust wrote:

>P=E5 m=E5 , 04/10/2004 klokka 18:24, skreiv Steve Dickson:
>
> =20
>
>>Hey Neil,
>>   =20
>>
>
>Hey! This is the client side NLM code... 8-)
> =20
>
Sorry buddy.... I'm having one of those days!!!! :-\

>Note that you probably also want to move the call to
>set_current_state(TASK_INTERRUPTIBLE) inside the loop. In that case yo=
u
>can also remove the call to set_current_state(TASK_RUNNING) ('cos
>schedule_timeout() will do that for you).
>
> =20
>
Ok...

>Also, why aren't you using the more standard DECLARE_WAITQUEUE(__wait)=
?
> =20
>
I guess I didn't realize that would be a better way to do it... I'll=20
look into to...

thanks,

SteveD.
