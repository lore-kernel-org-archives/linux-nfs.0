Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:33976 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751960AbbIPHP1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 03:15:27 -0400
From: Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Damien =?utf-8?Q?Th=C3=A9bault?= <damien.thebault@vitec.com>
Cc: "linux\@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trond.myklebust\@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	<1442386435.3756.282.camel@vitec.com>
Date: Wed, 16 Sep 2015 09:15:24 +0200
In-Reply-To: <1442386435.3756.282.camel@vitec.com> ("Damien =?utf-8?Q?Th?=
 =?utf-8?Q?=C3=A9bault=22's?=
	message of "Wed, 16 Sep 2015 06:53:57 +0000")
Message-ID: <87zj0mbzsj.fsf@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Damien,
 
 On mer., sept. 16 2015, Damien Thébault <damien.thebault@vitec.com> wrote:

> On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
>> I have a recent Marvell Armada 388 board here which uses the mvneta
>> driver.  I'm seeing some weird effects with NFS with it acting as a
>> client.
>
> Hello,
>
> I'm upgrading a Marvelle Armada 370 board using the mvneta driver from
> 4.0 to 4.2 and noticed issues with NFS booting.
> Basically, most of the time init returns with an error code, or
> programs segfault or throw illegal instructions.
>
> Since it worked fine on 4.0 I bisected until I found commit
> a84e32894191cfcbffa54180d78d7d4654d56c20 "net: mvneta: fix refilling
> for Rx DMA buffers".
>
> If I revert this commit, everything seems to get back to normal.
> Could you try it ? The two issues look very similar.

Actually there was a bug with this commit, but a fix had been submitted
and accepted yesterday, you can find him here:
https://patchwork.ozlabs.org/patch/518111/.

Thanks,

Gregory

>
> Regards

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
