Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:58379 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110Ab3I3RtC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 13:49:02 -0400
Message-ID: <5249B987.8020807@itwm.fraunhofer.de>
Date: Mon, 30 Sep 2013 19:48:55 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Miklos Szeredi <miklos@szeredi.hu>, Ric Wheeler <rwheeler@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Zach Brown <zab@redhat.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
References: <20130930143432.GG16579@fieldses.org>	 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>	 <52499026.3090802@redhat.com>	 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>	 <52498AA8.2090204@redhat.com>	 <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>	 <52498DB6.7060901@redhat.com>	 <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>	 <52498F68.8050200@redhat.com>	 <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com>	 <20130930163159.GA14242@tucsk.piliscsaba.szeredi.hu>	 <5249B21E.70603@itwm.fraunhofer.de> <1380563050.6501.15.camel@leira.trondhjem.org>
In-Reply-To: <1380563050.6501.15.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/30/2013 07:44 PM, Myklebust, Trond wrote:
> On Mon, 2013-09-30 at 19:17 +0200, Bernd Schubert wrote:
>> It would be nice if there would be way if the file system would get a
>> hint that the target file is supposed to be copy of another file. That
>> way distributed file systems could also create the target-file with the
>> correct meta-information (same storage targets as in-file has).
>> Well, if we cannot agree on that, file system with a custom protocol at
>> least can detect from 0 to SSIZE_MAX and then reset metadata. I'm not
>> sure if this would work for pNFS, though.
>
> splice() does not create new files. What you appear to be asking for
> lies way outside the scope of that system call interface.
>

Sorry I know, definitely outside the scope of splice, but in the context 
of offloaded file copies. So the question is, what is the best way to 
address/discuss that?

Thanks,
Bernd
