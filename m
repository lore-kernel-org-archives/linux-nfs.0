Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:57178 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbbGQOT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2015 10:19:58 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 4D8D2280373
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2015 16:19:56 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 4139E1229
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2015 16:19:55 +0200 (MEST)
Date: Fri, 17 Jul 2015 16:19:55 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Message-ID: <427466448.7094692.1437142795296.JavaMail.zimbra@desy.de>
In-Reply-To: <55A84431.3000603@gmail.com>
References: <1437064828-15387-1-git-send-email-tigran.mkrtchyan@desy.de> <55A84431.3000603@gmail.com>
Subject: Re: [PATCH] pynfs: reduce code duplication
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had look at other as well, but to merge them more radical changes required,
like moving shared code into a separated module and renaming nfs4.0 and nfs4.1
into something else, as python does not like dots in the module name.

Tigran.

----- Original Message -----
> From: "Kinglong Mee" <kinglongmee@gmail.com>
> To: "tigran mkrtchyan" <tigran.mkrtchyan@desy.de>, bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
> Sent: Friday, July 17, 2015 1:54:25 AM
> Subject: Re: [PATCH] pynfs: reduce code duplication

> On 7/17/2015 00:40, tigran.mkrtchyan@desy.de wrote:
>> From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> 
>> the test suite has two methods: check and checklist to
>> validate status codes of a compound operation. The both
>> methods are identical, except one of them accept a single
>> status code and other accepts a list.
>> 
>> Modify 'check' to accept a list as well to reduce code
>> duplication.
>> 
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>>  nfs4.1/server41tests/environment.py        | 40 ++++++++++++------------------
>>  nfs4.1/server41tests/st_current_stateid.py |  6 ++---
>>  nfs4.1/server41tests/st_delegation.py      |  6 ++---
>>  nfs4.1/server41tests/st_destroy_session.py |  2 +-
>>  nfs4.1/server41tests/st_exchange_id.py     |  4 +--
>>  nfs4.1/server41tests/st_lookup.py          | 10 ++++----
>>  nfs4.1/server41tests/st_open.py            |  2 +-
>>  nfs4.1/server41tests/st_reboot.py          |  2 +-
>>  nfs4.1/server41tests/st_rename.py          | 14 +++++------
>>  nfs4.1/server41tests/st_verify.py          |  4 +--
>>  10 files changed, 41 insertions(+), 49 deletions(-)
>> 
> 
> Make sense.
> I think clean all "checklist" is better.
> 
> "checklist" also exist in,
> nfs4.1/client41tests/environment.py
> nfs4.0/servertests/environment.py
> 
> Anyway this one is nice for nfs4.1 server.
> 
> thanks,
> Kinglong Mee
