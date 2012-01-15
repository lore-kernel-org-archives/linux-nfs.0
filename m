Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36764 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab2AOWbM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 17:31:12 -0500
Received: by vcbfo1 with SMTP id fo1so695715vcb.19
        for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 14:31:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120115205446.GA29596@fieldses.org>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
	<20120115205446.GA29596@fieldses.org>
Date: Sun, 15 Jan 2012 23:31:11 +0100
Message-ID: <CAFpJMDp3OvkCf0DPAvdZDPV_8F=8Z_C0euTjdtKxuiq3=rxMmw@mail.gmail.com>
Subject: Re: [PATCH 0/5] more test on current stateid processing
From: Tiramisu Mokka <kofemann@googlemail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-- kofemann
/** caffeinated mutations of the core personality */



On Sun, Jan 15, 2012 at 21:54, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sun, Jan 15, 2012 at 08:05:23PM +0100, Tigran Mkrtchyan wrote:
>>
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
> We should fix pynfs41 so no pnfs-dependent tests are run without "pnfs"
> being explicitly asked for on the commandline....

Well, echange_id has this information. pynfs have to respect it.

Tigran.
>
> --b.
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
>> --
>> 1.7.7.5
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
