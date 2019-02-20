Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E16B3C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 19:07:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C2F122081B
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 19:07:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725834AbfBTTHt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 14:07:49 -0500
Received: from smtp.engr.scu.edu ([129.210.16.13]:36048 "EHLO
        yavin.engr.scu.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1725822AbfBTTHt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 14:07:49 -0500
Received: from unimatrix3.engr.scu.edu (unimatrix3.engr.scu.edu [129.210.16.26])
        by yavin.engr.scu.edu (8.14.4/8.14.4) with ESMTP id x1KJ7jh6004980
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO);
        Wed, 20 Feb 2019 11:07:47 -0800
Received: from unimatrix3.engr.scu.edu (localhost [127.0.0.1])
        by unimatrix3.engr.scu.edu (8.14.4/8.14.4) with ESMTP id x1KJ7jq9031494;
        Wed, 20 Feb 2019 11:07:45 -0800
Received: from localhost (ctracy@localhost)
        by unimatrix3.engr.scu.edu (8.14.4/8.14.4/Submit) with ESMTP id x1KJ7j2l031490;
        Wed, 20 Feb 2019 11:07:45 -0800
X-Authentication-Warning: unimatrix3.engr.scu.edu: ctracy owned process doing -bs
Date:   Wed, 20 Feb 2019 11:07:45 -0800 (PST)
From:   Chris Tracy <ctracy@engr.scu.edu>
To:     "J. Bruce Fields" <bfields@fieldses.org>
cc:     linux-nfs@vger.kernel.org
Subject: Re: Linux NFS v4.1 server support for dynamic slot allocation?
In-Reply-To: <20190220171027.GA4399@fieldses.org>
Message-ID: <alpine.LRH.2.21.1902201017450.7591@unimatrix3.engr.scu.edu>
References: <alpine.LRH.2.21.1902181301001.4186@unimatrix3.engr.scu.edu> <20190220171027.GA4399@fieldses.org>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Bruce,

> They'd probably need reworking.  The latest discussion I can find is:
>
> 	https://lore.kernel.org/linux-nfs/CAABAsM6vDOaudUZYWH23oGiWGqX5Bd1YbCDnL6L=pxzMXgZzaw@mail.gmail.com/

 	Ahh, thanks.  If server-side dynamic slot allocation does get 
added at some point, I'll certainly be interested to test.

>> 	Looking at the code (both in CentOS's 3.10.0-957.5.1.el7.x86_64 and
>> in the 4.20.8 mainline), it seems the value that would need to
>> change is the preprocessor define NFSD_CACHE_SIZE_SLOTS_PER_SESSION.
>> This is fixed at 32, and while it's a bit more complex than this,
>> the code in nfs4_get_drc_mem (fs/nfsd/nfs4state.c) basically sets
>> the per-client session slot limit to '(int)(32/3)' which is where
>> the '10' comes from.
>
> Thanks for the report!
>
> I think the limit should only be that low if the client requests very
> large slots.  Do your clients have 35c036ef4a72 "nfs: RPC_MAX_AUTH_SIZE
> is in bytes" applied?

 	They do, yes.

 	I'm nothing close to a kernel hacker, but the issue seems to come 
down to nfsd4_get_drc_mem().  Yes, it calls slot_bytes() which uses 
ca->maxresp_cached (the size of which is impacted by the referenced patch) 
but the slot size's impact on the number of slots returned seems to pale 
in comparison to this bit in nfsd4_get_drc_mem():

-----------
avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
 		nfsd_drc_max_mem - nfsd_drc_mem_used);
/*
  * Never use more than a third of the remaining memory,
  * unless it's the only way to give this client a slot:
  */
avail = clamp_t(int, avail, slotsize, avail/3);
num = min_t(int, num, avail / slotsize);
-----------

That first min() call seems almost always guaranteed to use 
NFSD_MAX_MEM_PER_SESSION, at least in my scale of testing where the number 
of clients and connections is relatively low.  Since this is defined as:

-----------
/* Maximum  session per slot cache size */
#define NFSD_SLOT_CACHE_SIZE		2048
/* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
#define NFSD_CACHE_SIZE_SLOTS_PER_SESSION	32
#define NFSD_MAX_MEM_PER_SESSION  \
 	(NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)
-----------

NFSD_MAX_MEM_PER_SESSION is 65,536 bytes, and thus that's as big as 
'avail' can ever be.  'slotsize' is the return value of 'slot_bytes(ca)' 
which uses 'ca->maxresp_cached' as referenced above, and at least here 
ends up returning a value of 2128.  So the code then clamp's 'avail' to 
between 2128 and 21845 (65536/3) and then goes on to set 'num' to the 
minimum of the client request (64 in this case) or 10 (21845/2128).

 	Unfortunately, I don't understand the code well enough to suggest 
an alternative approach.  However, it does seem to me that it can 
currently only ever return a maximum of 10 slots, which seems low, 
especially in the low-client, high bandwidth (10G or more) case that I'm 
dealing with.

>> 	Is there something else I've missed somewhere that allows adjusting
>> the server-side session slot limit to be more than 10 without having
>> to compile a custom version of nfsd.ko?
>
> No.  It might be a good idea, though really I think your setup should
> just work out of the box.

 	Out of the box would be great, but I'd be happy with a manual 
knob.  I'm just looking for some way to control the per-client slot count 
on the server side.  (Something as conceptually simple as increasing 
NFSD_CACHE_SIZE_SLOTS_PER_SESSION to 64, removing the /3, and then 
exposing an nfsd 'max_slots_per_session' parameter, capped at 64, would 
work for me, I think)

 	And in fairness, it's not like it's broken out of the box.  I'm 
complaining about single-client read speeds being 600MB/s with NFS v3/v4.0 
but "only" ~440MB/s with NFS v4.1/v4.2.  It would be nice to eventually 
have the same level of performance available, but it's certainly usable.

 	Thanks,

 	Chris

NOTE: Looking at it now, I wonder if the intent of the comment block in 
nfsd4_get_drc_mem() would be better expressed:

--------
avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
 		nfsd_drc_max_mem - nfsd_drc_mem_used);
/*
  * Never use more than a third of the remaining memory,
  * unless it's the only way to give this client a slot:
  */
avail = clamp_t(int, avail, slotsize,
 	(nfsd_drc_max_mem - nfsd_drc_mem_used)/3);
num = min_t(int, num, avail / slotsize);
--------

ensuring that 'avail' can never be more than a third of the DRC memory 
available, rather than a third of NFSD_MAX_MEM_PER_SESSION.  That would at 
least allow each client to use up to 32 slots, which would be a 
significant improvement.  (Though some sort of manual knob or auto-tuning 
would be nice)
