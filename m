Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750829AbeAaT5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 14:57:36 -0500
Subject: Re: Question about random UDP port on rpcbind 0.2.3
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
 <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
 <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <27ec9304-5763-9885-b3c9-246c395e6986@RedHat.com>
Date: Wed, 31 Jan 2018 14:57:35 -0500
MIME-Version: 1.0
In-Reply-To: <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/31/2018 02:43 PM, Chuck Lever wrote:
> 
> 
>> On Jan 31, 2018, at 2:31 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 01/29/2018 01:44 AM, Naruto Nguyen wrote:
>>> Hello,
>>>
>>> Just would like to add for more information, when I start rpcbind
>>> normally, not via systemd, the random UDP is still opened
>>>
>>> Could you please share any ideas on this?
>> The bound UDP socket is used for remote calls... Where rpcbind
>> is asked to make a remote RPC for another caller... 
>>
>> Antiquated? yes.. but harmless.
> 
> Not quite harmless. It can occupy a privileged port that belongs
> to a real service.
fair enough... 

> 
> We should change rpcbind to retain CAP_NET_BIND_SERVICE, so that
> it doesn't have to hold onto that port indefinitely. It should
> be able to bind to an outgoing privileged port whenever it needs
> one.
Or we just avoid know ports like sm-notify does.

steved.

> 
> 
>> steved.
>>
>>>
>>> Brs,
>>> Bao
>>>
>>> On 27 January 2018 at 19:50, Naruto Nguyen <narutonguyen2018@gmail.com> wrote:
>>>> I would like to ask you a question regarding the new random UDP port
>>>> in rpcbind 0.2.3.
>>>>
>>>> In rpcbind 0.2.3, when I start rpcbind (version 0.2.3) through
>>>> rpcbind.service, then I do netstat
>>>>
>>>> udp        0      0 0.0.0.0:111             0.0.0.0:*
>>>>         10408/rpcbind
>>>> udp        0      0 0.0.0.0:831             0.0.0.0:*
>>>>         10408/rpcbind
>>>> udp6       0      0 :::111                  :::*
>>>>         10408/rpcbind
>>>> udp6       0      0 :::831                  :::*
>>>>         10408/rpcbind
>>>>
>>>> The rpcbind does not only listen on port 111 but also on a random udp
>>>> port "831" in this case, this port is changed every time the rpcbind
>>>> service retstarts. And it listens on 0.0.0.0 so it opens a hole on
>>>> security. Could you please let me know what this port is for and is
>>>> there any way to avoid that like force it listen on a internal
>>>> interface rather than on any interfaces like that? I do not see the
>>>> random port on rpcbind 0.2.1, not sure why? As the rpcbind is started
>>>> from systemd so "-h" option is invalid as the man page says:
>>>>
>>>>
>>>>   -h      Specify specific IP addresses to bind to for UDP requests.
>>>> This option may be specified multiple times and can be used to
>>>> restrict the interfaces rpcbind will respond to.  Note that when
>>>> rpcbind is controlled via sys-
>>>>             temd's socket activation, the -h option is ignored. In
>>>> this case, you need to edit the ListenStream and ListenDgram
>>>> definitions in /usr/lib/systemd/system/rpcbind.socket instead.
>>>>
>>>> Thanks a lot,
>>>> Brs,
>>>> Naruto
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
