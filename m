Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55670 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836Ab2AXMSU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2012 07:18:20 -0500
Received: by wics10 with SMTP id s10so2890726wic.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 04:18:19 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4F1E9BB3.1000406@tonian.com>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
	<4F1E9BB3.1000406@tonian.com>
Date: Tue, 24 Jan 2012 13:18:19 +0100
Message-ID: <CAGue13rZcMxT0L=87s1s4T6odythXqoAFpM0t-Sh049-cDA8+w@mail.gmail.com>
Subject: Re: [PATCH 0/5] more test on current stateid processing
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2012 at 12:53 PM, Benny Halevy <bhalevy@tonian.com> wrote:
> On 2012-01-15 21:05, Tigran Mkrtchyan wrote:
>> This is the result of testing my changes in linux:
>>
>> $ ./testserver.py  --maketree 192.168.178.20:/tmp currentstateid
>> .....
>>
>> **************************************************
>> CSID1    st_current_stateid.testOpenAndClose                      : PASS
>> CSID2    st_current_stateid.testLockLockU                         : PASS
>> CSID3    st_current_stateid.testOpenWriteClose                    : PASS
>> CSID4    st_current_stateid.testLockWriteLocku                    : PASS
>> CSID5    st_current_stateid.testOpenPutrootfhClose                : PASS
>> CSID6    st_current_stateid.testCloseNoStateid                    : PASS
>> CSID7    st_current_stateid.testOpenLayoutGet                     : FAILURE
>>            OP_LAYOUTGET should return NFS4_OK, instead got
>>            NFS4ERR_NOTSUPP
>
> I guess this is not against my kernel but rather against Bruce's / mainline?

Yes, This is against Bruce's tree. With your I get LAYOUT_TRYLATER :-D

Tigran.

>
> Benny
>
>> CSID8    st_current_stateid.testOpenSetattr                       : PASS
>> CSID9    st_current_stateid.testOpenFreestateidClose              : PA
>>
>> **************************************************
>> $
>>
>> Tigran Mkrtchyan (5):
>>   client: move current stateid test into a dedicated module
>>   client: test current stateid processing on PUTROOTFH
>>   client: test current stateid processing with OPEN+LAYOUTGET in a
>>     single compound
>>   client: test current stateid processing with OPEN and SETATTR
>>   client: test OPEN+FREE_STETEID+CLOSE in a single compound
>>
>>  nfs4.1/server41tests/__init__.py           |    1 +
>>  nfs4.1/server41tests/st_current_stateid.py |  161 ++++++++++++++++++++++++++++
>>  nfs4.1/server41tests/st_open.py            |   76 -------------
>>  3 files changed, 162 insertions(+), 76 deletions(-)
>>  create mode 100644 nfs4.1/server41tests/st_current_stateid.py
>>
