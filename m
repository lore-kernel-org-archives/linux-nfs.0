Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbeAaTby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 14:31:54 -0500
Subject: Re: Question about random UDP port on rpcbind 0.2.3
To: Naruto Nguyen <narutonguyen2018@gmail.com>,
        linux-nfs@vger.kernel.org
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
Date: Wed, 31 Jan 2018 14:31:53 -0500
MIME-Version: 1.0
In-Reply-To: <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/29/2018 01:44 AM, Naruto Nguyen wrote:
> Hello,
> 
> Just would like to add for more information, when I start rpcbind
> normally, not via systemd, the random UDP is still opened
> 
> Could you please share any ideas on this?
The bound UDP socket is used for remote calls... Where rpcbind
is asked to make a remote RPC for another caller... 

Antiquated? yes.. but harmless.

steved.

> 
> Brs,
> Bao
> 
> On 27 January 2018 at 19:50, Naruto Nguyen <narutonguyen2018@gmail.com> wrote:
>> I would like to ask you a question regarding the new random UDP port
>> in rpcbind 0.2.3.
>>
>> In rpcbind 0.2.3, when I start rpcbind (version 0.2.3) through
>> rpcbind.service, then I do netstat
>>
>> udp        0      0 0.0.0.0:111             0.0.0.0:*
>>          10408/rpcbind
>> udp        0      0 0.0.0.0:831             0.0.0.0:*
>>          10408/rpcbind
>> udp6       0      0 :::111                  :::*
>>          10408/rpcbind
>> udp6       0      0 :::831                  :::*
>>          10408/rpcbind
>>
>> The rpcbind does not only listen on port 111 but also on a random udp
>> port "831" in this case, this port is changed every time the rpcbind
>> service retstarts. And it listens on 0.0.0.0 so it opens a hole on
>> security. Could you please let me know what this port is for and is
>> there any way to avoid that like force it listen on a internal
>> interface rather than on any interfaces like that? I do not see the
>> random port on rpcbind 0.2.1, not sure why? As the rpcbind is started
>> from systemd so "-h" option is invalid as the man page says:
>>
>>
>>    -h      Specify specific IP addresses to bind to for UDP requests.
>> This option may be specified multiple times and can be used to
>> restrict the interfaces rpcbind will respond to.  Note that when
>> rpcbind is controlled via sys-
>>              temd's socket activation, the -h option is ignored. In
>> this case, you need to edit the ListenStream and ListenDgram
>> definitions in /usr/lib/systemd/system/rpcbind.socket instead.
>>
>> Thanks a lot,
>> Brs,
>> Naruto
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
