Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:51308 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab1DZOjX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2011 10:39:23 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id C7D9617EA
	for <linux-nfs@vger.kernel.org>; Tue, 26 Apr 2011 16:39:22 +0200 (MEST)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id C105013E8B
	for <linux-nfs@vger.kernel.org>; Tue, 26 Apr 2011 16:39:22 +0200 (MEST)
Message-ID: <4DB6D8C3.1070801@desy.de>
Date: Tue, 26 Apr 2011 16:37:55 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: pNFS read/write behavior change in 2.6.39
References: <4DB6D0CC.4050601@desy.de> <1303828194.1785.21.camel@lade.trondhjem.org>
In-Reply-To: <1303828194.1785.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/26/2011 04:29 PM, Trond Myklebust wrote:
> On Tue, 2011-04-26 at 16:03 +0200, Tigran Mkrtchyan wrote:
>> I run 2.6.39-0.rc4.git2.0 build for fedora-16 build by redhat.
>> Probably Steve and Bruce can comment on the patch set.
>>
>> My observation is that state id provided by client on read to
>> DS dit not contain correct stateid:
>>
>> struct stateid4 {
>>           uint32_t        seqid;
>>           opaque          other[12];
>> };
>>
>> The seqid equals to zero when client send it to DS which is not the
>> value returned on OPEN.
> Why do you think this is a bug? Section 8.2.2 of RFC5661 not only allows
> this behaviour, it actually suggests it is appropriate for READ and
> WRITE since it means that the server isn't forced to constantly check
> the seqid value.
Well, It's not a bug, but it's not the behavior we was testing at 
Connectathon.
My expectation was that during interoperability testing we catch such 
changes.

Tigran.
> Trond

