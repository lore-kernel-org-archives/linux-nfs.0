Return-Path: <tigran.mkrtchyan@desy.de>
Date: Fri, 8 May 2015 15:00:48 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <752919938.1601268.1431090048609.JavaMail.zimbra@desy.de>
In-Reply-To: <alpine.OSX.2.19.9992.1505080824560.656@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com> <110354172.1516782.1431074928783.JavaMail.zimbra@desy.de> <alpine.OSX.2.19.9992.1505080824560.656@planck.local>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

probably you can simulate, as Olga has suggested, with fault injection.
I can I can prepare a snadalone version of your server, which returns
BAD_STATEID on any IO request.

Tigran.

----- Original Message -----
> From: "Benjamin Coddington" <bcodding@redhat.com>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Trond Myklebust" <trond.myklebust@primarydata.com>, "linux-nfs"
> <linux-nfs@vger.kernel.org>
> Sent: Friday, May 8, 2015 2:25:19 PM
> Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID

> On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:
> 
>> Hi Olga,
>>
>> I believe we see the same infinite loop without delegation with RHEL6/7
>> kernels, but without delegation being involved. Currently, on the server
>> side, if client looping is detected, we return RESOURCE. This breaks the
>> loop and application gets an IO error.
>>
>> Your fix is only covers the delegation case isn't it?
>>
>> Tigran.
> 
> Tigran, do you have a BZ or can you tell me how to reproduce this?
> 
> Ben
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
