Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0759AC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 22:48:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D396F217D9
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 22:48:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731937AbfBRWsT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 17:48:19 -0500
Received: from smtp.engr.scu.edu ([129.210.16.13]:52789 "EHLO
        yavin.engr.scu.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1731964AbfBRWsP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 17:48:15 -0500
X-Greylist: delayed 3708 seconds by postgrey-1.27 at vger.kernel.org; Mon, 18 Feb 2019 17:48:15 EST
Received: from unimatrix3.engr.scu.edu (unimatrix3.engr.scu.edu [129.210.16.26])
        by yavin.engr.scu.edu (8.14.4/8.14.4) with ESMTP id x1ILkPVU005697
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2019 13:46:27 -0800
Received: from unimatrix3.engr.scu.edu (localhost [127.0.0.1])
        by unimatrix3.engr.scu.edu (8.14.4/8.14.4) with ESMTP id x1ILkPxR003649
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2019 13:46:25 -0800
Received: from localhost (ctracy@localhost)
        by unimatrix3.engr.scu.edu (8.14.4/8.14.4/Submit) with ESMTP id x1ILkOTf003645
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2019 13:46:25 -0800
X-Authentication-Warning: unimatrix3.engr.scu.edu: ctracy owned process doing -bs
Date:   Mon, 18 Feb 2019 13:46:24 -0800 (PST)
From:   Chris Tracy <ctracy@engr.scu.edu>
To:     linux-nfs@vger.kernel.org
Subject: Linux NFS v4.1 server support for dynamic slot allocation?
Message-ID: <alpine.LRH.2.21.1902181301001.4186@unimatrix3.engr.scu.edu>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

 	Hopefully I'm not missing something obvious, but I'm curious 
whatever happened to the patch series from late 2012 that added dynamic 
v4.1 session slot allocation support to nfsd:

https://www.spinics.net/lists/linux-nfs/msg34390.html

The corresponding nfs client patches were integrated, but the nfsd series 
seems to have been left out due to release timing:

https://www.spinics.net/lists/linux-nfs/msg34505.html

However, they don't seem to ever have been integrated or discussed again. 
Were there other issues that prevented its inclusion in the intervening 
time?

 	Alternatively, is there some admin-tweakable knob for controlling 
the number of slots available per-session on the NFS v4.1 server 
(nfsd.ko), similar to the 'max_session_slots' client-side parameter for 
nfs.ko?

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/fs/nfs?id=ef159e9177cc5a09e6174796dde0b2d243ddf28b

 	I ask because I'm currently standing up a (very) modest HPC 
cluster PoC (1 server, 8 client nodes, all 10Gbit, all running CentOS 7.6) 
and figured that was a good enough excuse to finally move away from NFS v3 
and investigate NFS v4.x.  However, initial performance testing showed 
that while NFS v4.0 was essentially identical to v3, NFS v4.2 (and v4.1) 
were around 25% slower.

 	Looking at the traffic in wireshark, I see that in CREATE_SESSION, 
the client sets ca_maxrequests to 64 (consistent with the value of 
'max_session_slots') but the server always replies with a value of 10 for 
ca_maxreqests.  This seems to be the source of the performance issue, 
since if I fallback to v4.0 or v3, but set nfsd to use only 10 threads in 
nfs.conf, I get roughly equivalent performance to v4.2.

 	Looking at the code (both in CentOS's 3.10.0-957.5.1.el7.x86_64 
and in the 4.20.8 mainline), it seems the value that would need to change 
is the preprocessor define NFSD_CACHE_SIZE_SLOTS_PER_SESSION.  This is 
fixed at 32, and while it's a bit more complex than this, the code in 
nfs4_get_drc_mem (fs/nfsd/nfs4state.c) basically sets the per-client 
session slot limit to '(int)(32/3)' which is where the '10' comes from.

 	This brings me back to the patch series mentioned above as this 
one from it:

https://patchwork.kernel.org/patch/1819971/

seems to allow the per-session limit to dynamically increase at least all 
the way to 32. (instead of being fixed at a max of 10)

 	Is there something else I've missed somewhere that allows 
adjusting the server-side session slot limit to be more than 10 without 
having to compile a custom version of nfsd.ko?

 	Thanks,

 	Chris

---------------------------------
Chris Tracy
System/Network Administrator
School of Engineering
Santa Clara University
"Wherever you go, there you are."
