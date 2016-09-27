Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:18234 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936563AbcI0RTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Sep 2016 13:19:14 -0400
Subject: Re: [PATCH 0/2] NFS: Use complete() instead complete_all()
To: Daniel Wagner <daniel.wagner@bmw-carit.de>,
        Daniel Wagner <wagi@monom.org>, <linux-nfs@vger.kernel.org>
References: <1474545269-8694-1-git-send-email-wagi@monom.org>
 <ca2d158b-ebdd-a709-a63a-421a11d8ca0a@Netapp.com>
 <74468e19-772d-41b8-b7df-c0aa845e52ab@bmw-carit.de>
 <ded5c166-aa7e-ce61-8190-ffc15c7d1b12@Netapp.com>
 <3bb018a5-9257-ef95-e5bf-106a820120ea@bmw-carit.de>
 <99846ad0-6b62-0bc4-f03b-cdc98b702af5@bmw-carit.de>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <f7075c3b-c640-e7ee-7dfb-2c37ff1a3caa@Netapp.com>
Date: Tue, 27 Sep 2016 13:15:19 -0400
MIME-Version: 1.0
In-Reply-To: <99846ad0-6b62-0bc4-f03b-cdc98b702af5@bmw-carit.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/27/2016 04:33 AM, Daniel Wagner wrote:
> On 09/27/2016 09:42 AM, Daniel Wagner wrote:
>> Failures: generic/035 generic/087 generic/088 generic/089 generic/126 generic/184 generic/285 generic/347 generic/350
>> Failed 9 of 62 tests
>>
>> Hmm, not sure if this good or bad. Does it help?
> 
> FWIW, running the same tests on non patched kernel gives the same result:

Thanks for testing!  If it has the same results before and after your patches then you should be good :).  I've seen different sets of failed tests for different underlying filesystems, so I don't think it's a big deal that we have different failed tests here.

Thanks again,
Anna

> 
> Failures: generic/035 generic/087 generic/088 generic/089 generic/126 generic/184 generic/285 generic/347 generic/350
> Failed 9 of 62 tests
> 
> 
> 

