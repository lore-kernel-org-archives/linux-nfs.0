Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755073Ab3I3Ptg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 11:49:36 -0400
Message-ID: <52498F68.8050200@redhat.com>
Date: Mon, 30 Sep 2013 09:49:12 -0500
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Miklos Szeredi <miklos@szeredi.hu>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zach Brown <zab@redhat.com>, Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
References: <20130925210742.GG30372@lenny.home.zabbo.net> <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com> <20130926185508.GO30372@lenny.home.zabbo.net> <5244A68F.906@redhat.com> <20130927200550.GA22640@fieldses.org> <20130927205013.GZ30372@lenny.home.zabbo.net> <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com> <52474839.2080201@redhat.com> <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com> <20130930143432.GG16579@fieldses.org> <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com> <52499026.3090802@redhat.com> <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com> <52498AA8.2090204@redhat.com> <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com> <52498DB6.7060901@redhat.com> <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
In-Reply-To: <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/30/2013 10:46 AM, Miklos Szeredi wrote:
> On Mon, Sep 30, 2013 at 4:41 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
>> The way the array based offload (and some software side reflink works) is
>> not a byte by byte copy. We cannot assume that a valid count can be returned
>> or that such a count would be an indication of a sequential segment of good
>> data.  The whole thing would normally have to be reissued.
>>
>> To make that a true assumption, you would have to mandate that in each of
>> the specifications (and sw targets)...
> You're missing my point.
>
>   - user issues SIZE_MAX splice request
>   - fs issues *64M* (or whatever) request to offload
>   - when that completes *fully* then we return 64M to userspace
>   - if it completes partially, then we return an error to userspace
>
> Again, wouldn't that work?
>
> Thanks,
> Miklos

Yes, if you send a copy offload command and it works, you can assume that it 
worked fully. It would be pretty interesting if that were not true :)

If it fails, we cannot assume anything about partial completion.

Ric

