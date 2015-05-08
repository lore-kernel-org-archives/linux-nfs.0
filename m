Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:53419 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbbEHNNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 09:13:16 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 9D8DA280897
	for <linux-nfs@vger.kernel.org>; Fri,  8 May 2015 15:13:14 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 91D4F14D4
	for <linux-nfs@vger.kernel.org>; Fri,  8 May 2015 15:13:14 +0200 (MEST)
Date: Fri, 8 May 2015 15:13:13 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <418948160.1602341.1431090793667.JavaMail.zimbra@desy.de>
In-Reply-To: <alpine.OSX.2.19.9992.1505080906070.656@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com> <110354172.1516782.1431074928783.JavaMail.zimbra@desy.de> <alpine.OSX.2.19.9992.1505080824560.656@planck.local> <752919938.1601268.1431090048609.JavaMail.zimbra@desy.de> <alpine.OSX.2.19.9992.1505080906070.656@planck.local>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No, Olga's case includes delegation, which our server does not supports.

Tigran.

----- Original Message -----
> From: "Benjamin Coddington" <bcodding@redhat.com>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Trond Myklebust" <trond.myklebust@primarydata.com>, "linux-nfs"
> <linux-nfs@vger.kernel.org>
> Sent: Friday, May 8, 2015 3:08:03 PM
> Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID

> Yes, I've done that, and the client's behavior correctly cycles through
> OPEN, then READ with the new stateid.  Are you able to create what Olga's
> talking about -- which is (I believe) a loop of just OPENs?
> 
> Ben
> 
> On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:
> 
>> Hi Ben,
>>
>> probably you can simulate, as Olga has suggested, with fault injection.
>> I can I can prepare a snadalone version of your server, which returns
>> BAD_STATEID on any IO request.
>>
>> Tigran.
>>
>> ----- Original Message -----
>> > From: "Benjamin Coddington" <bcodding@redhat.com>
>> > To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>> > Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Trond Myklebust"
>> > <trond.myklebust@primarydata.com>, "linux-nfs"
>> > <linux-nfs@vger.kernel.org>
>> > Sent: Friday, May 8, 2015 2:25:19 PM
>> > Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
>> > BAD_STATEID
>>
>> > On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:
>> >
>> >> Hi Olga,
>> >>
>> >> I believe we see the same infinite loop without delegation with RHEL6/7
>> >> kernels, but without delegation being involved. Currently, on the server
>> >> side, if client looping is detected, we return RESOURCE. This breaks the
>> >> loop and application gets an IO error.
>> >>
>> >> Your fix is only covers the delegation case isn't it?
>> >>
>> >> Tigran.
>> >
>> > Tigran, do you have a BZ or can you tell me how to reproduce this?
>> >
>> > Ben
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
