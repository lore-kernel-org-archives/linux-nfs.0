Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873Ab3I1VVk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Sep 2013 17:21:40 -0400
Message-ID: <52474839.2080201@redhat.com>
Date: Sat, 28 Sep 2013 17:20:57 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Miklos Szeredi <miklos@szeredi.hu>, Zach Brown <zab@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
References: <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com> <20130925183828.GA30372@lenny.home.zabbo.net> <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com> <20130925190620.GB30372@lenny.home.zabbo.net> <20130925195526.GA18971@fieldses.org> <20130925210742.GG30372@lenny.home.zabbo.net> <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com> <20130926185508.GO30372@lenny.home.zabbo.net>	<5244A68F.906@redhat.com> <20130927200550.GA22640@fieldses.org> <20130927205013.GZ30372@lenny.home.zabbo.net> <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/28/2013 11:20 AM, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Miklos Szeredi [mailto:miklos@szeredi.hu]
>> Sent: Saturday, September 28, 2013 12:50 AM
>> To: Zach Brown
>> Cc: J. Bruce Fields; Ric Wheeler; Anna Schumaker; Kernel Mailing List; Linux-
>> Fsdevel; linux-nfs@vger.kernel.org; Myklebust, Trond; Schumaker, Bryan;
>> Martin K. Petersen; Jens Axboe; Mark Fasheh; Joel Becker; Eric Wong
>> Subject: Re: [RFC] extending splice for copy offloading
>>
>> On Fri, Sep 27, 2013 at 10:50 PM, Zach Brown <zab@redhat.com> wrote:
>>>> Also, I don't get the first option above at all.  The argument is
>>>> that it's safer to have more copies?  How much safety does another
>>>> copy on the same disk really give you?  Do systems that do dedup
>>>> provide interfaces to turn it off per-file?
>> I don't see the safety argument very compelling either.  There are real
>> semantic differences, however: ENOSPC on a write to a
>> (apparentlíy) already allocated block.  That could be a bit unexpected.  Do we
>> need a fallocate extension to deal with shared blocks?
> The above has been the case for all enterprise storage arrays ever since the invention of snapshots. The NFSv4.2 spec does allow you to set a per-file attribute that causes the storage server to always preallocate enough buffers to guarantee that you can rewrite the entire file, however the fact that we've lived without it for said 20 years leads me to believe that demand for it is going to be limited. I haven't put it top of the list of features we care to implement...
>
> Cheers,
>     Trond

I agree - this has been common behaviour for a very long time in the array 
space. Even without an array,  this is the same as overwriting a block in btrfs 
or any file system with a read-write LVM snapshot.

Regards,

Ric

