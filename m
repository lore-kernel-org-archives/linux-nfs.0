Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36660 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab2FKWSZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 18:18:25 -0400
Message-ID: <4FD66E9F.708@panasas.com>
Date: Tue, 12 Jun 2012 01:18:07 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andy Adamson <androsadamson@gmail.com>, NFSv4 <nfsv4@ietf.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: RFC 5661 LAYOUTRETURN clarification.
References: <CAHVgHyUpM0rQWqO5-id+FohPKm1Lk=kkekf7HqzpfKcfvxx23A@mail.gmail.com>  <4FD63BAF.8040107@panasas.com> <1339441159.19775.25.camel@lade.trondhjem.org>
In-Reply-To: <1339441159.19775.25.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 09:59 PM, Myklebust, Trond wrote:

> On Mon, 2012-06-11 at 21:40 +0300, Boaz Harrosh wrote:
> 
>> And again, please explain why do you want it. What is wrong with the
>> case we all agree with? ie: "Client can not call LAYOUTRETURN until
>> all in-flight RPCs return, with or without an error"
> 
> Who "agreed" to this? This would mean that if the DS goes down, we can't
> ever send LAYOUTRETURN which is patently wrong.
> 


"DS goes down" is under the above "RPC return an error" the error condition
of an RPC is well defined.

>From what of my words did you understand that I said
	"we can't ever send a LAYOUTRETURN"

If my English is wrongly worded. Which is perfectly possible. Please correct
me so I can learn. Did you honestly think that's what I meant? 

I meant we all agree, that this case is covered by RFC. That is  - no one would
accuse a client who does that, as violating the RFC.

And again my question. The motivation?

Thanks
Boaz
