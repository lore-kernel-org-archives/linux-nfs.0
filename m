Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54519 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab2GZMQS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 08:16:18 -0400
Message-ID: <50113504.3060607@panasas.com>
Date: Thu, 26 Jul 2012 15:16:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com> <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com> <5010F1DF.3060905@panasas.com> <CA+a=Yy5YNKp2tkOreYwV9sfm7whw3_KeRj_YCCL3abG6+csK=g@mail.gmail.com>
In-Reply-To: <CA+a=Yy5YNKp2tkOreYwV9sfm7whw3_KeRj_YCCL3abG6+csK=g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/26/2012 11:25 AM, Peng Tao wrote:

> For these two sectors, I need to allocate two pages... Just look at
> struct bio_vec.
> 


NO! I know all about bio_vecs

You need 1024 bytes, and 2 x one entry BIOs which is a few bytes, where
did you get the "two pages" from?

