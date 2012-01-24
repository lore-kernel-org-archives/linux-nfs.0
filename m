Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:43207 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464Ab2AXLx2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2012 06:53:28 -0500
Received: by werb13 with SMTP id b13so2879704wer.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 03:53:27 -0800 (PST)
Message-ID: <4F1E9BB3.1000406@tonian.com>
Date: Tue, 24 Jan 2012 13:53:23 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH 0/5] more test on current stateid processing
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-01-15 21:05, Tigran Mkrtchyan wrote:
> This is the result of testing my changes in linux:
> 
> $ ./testserver.py  --maketree 192.168.178.20:/tmp currentstateid
> .....
> 
> **************************************************
> CSID1    st_current_stateid.testOpenAndClose                      : PASS
> CSID2    st_current_stateid.testLockLockU                         : PASS
> CSID3    st_current_stateid.testOpenWriteClose                    : PASS
> CSID4    st_current_stateid.testLockWriteLocku                    : PASS
> CSID5    st_current_stateid.testOpenPutrootfhClose                : PASS
> CSID6    st_current_stateid.testCloseNoStateid                    : PASS
> CSID7    st_current_stateid.testOpenLayoutGet                     : FAILURE
>            OP_LAYOUTGET should return NFS4_OK, instead got
>            NFS4ERR_NOTSUPP

I guess this is not against my kernel but rather against Bruce's / mainline?

Benny

> CSID8    st_current_stateid.testOpenSetattr                       : PASS
> CSID9    st_current_stateid.testOpenFreestateidClose              : PA
> 
> **************************************************
> $
> 
> Tigran Mkrtchyan (5):
>   client: move current stateid test into a dedicated module
>   client: test current stateid processing on PUTROOTFH
>   client: test current stateid processing with OPEN+LAYOUTGET in a
>     single compound
>   client: test current stateid processing with OPEN and SETATTR
>   client: test OPEN+FREE_STETEID+CLOSE in a single compound
> 
>  nfs4.1/server41tests/__init__.py           |    1 +
>  nfs4.1/server41tests/st_current_stateid.py |  161 ++++++++++++++++++++++++++++
>  nfs4.1/server41tests/st_open.py            |   76 -------------
>  3 files changed, 162 insertions(+), 76 deletions(-)
>  create mode 100644 nfs4.1/server41tests/st_current_stateid.py
> 
