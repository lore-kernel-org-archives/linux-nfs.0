Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57724 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700Ab2AQQmG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:42:06 -0500
Date: Tue, 17 Jan 2012 11:42:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] more test on current stateid processing
Message-ID: <20120117164205.GD13977@fieldses.org>
References: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied the pynfs changes, thanks!

--b.

On Sun, Jan 15, 2012 at 08:05:23PM +0100, Tigran Mkrtchyan wrote:
> 
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
> -- 
> 1.7.7.5
> 
