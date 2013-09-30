Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755674Ab3I3UJZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 16:09:25 -0400
Message-ID: <5249DA50.5060105@redhat.com>
Date: Mon, 30 Sep 2013 16:08:48 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
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
References: <20130930143432.GG16579@fieldses.org>			 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>			 <52499026.3090802@redhat.com>			 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>			 <52498AA8.2090204@redhat.com>			 <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>			 <52498DB6.7060901@redhat.com>			 <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>			 <52498F68.8050200@redhat.com>			 <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com>			 <20130930163159.GA14242@tucsk.piliscsaba.szeredi.hu>			 <5249B21E.70603@itwm.fraunhofer.de>		 <1380563050.6501.15.camel@leira.trondhjem.org>		 <5249B987.8020807@itwm.fraunhofer.de>	 <1380564126.6501.23.camel@leira.trondhjem.org>	 <5249C7C7.7020207@itwm.fraunhofer.de> <1380569663.6501.63.camel@leira.trondhjem.org> <5249D86A.7080603@itwm.fraunhofer.de>
In-Reply-To: <5249D86A.7080603@itwm.fraunhofer.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/30/2013 04:00 PM, Bernd Schubert wrote:
> pNFS, FhGFS, Lustre, Ceph, etc., all of them shall implement their own 
> interface? And userspace needs to address all of them differently? 

The NFS and SCSI groups have each defined a standard which Zach's proposal 
abstracts into a common user API.

Distributed file systems tend to be rather unique and do not have similar 
standard bodies, but a lot of them could hide server specific implementations 
under the current proposed interfaces.

What is not a good idea is to drag out the core, simple copy offload discussion 
for another 5 years to pull in every odd use case :)

ric

