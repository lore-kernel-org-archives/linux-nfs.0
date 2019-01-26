Return-Path: <SRS0=byNy=QC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8152BC282C9
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Jan 2019 17:59:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5463B218A6
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Jan 2019 17:59:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548525556;
	bh=usTGDW7vA49jM6scQlaSGxneW8X7HuIVnkyGGrx+FAg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=U/KC6ORcw2+lSsZZ4doAd7osSxGb2ghZk9b8Ph/eZni2JzBR09vA/2sKff5LG6xE0
	 gxznOreJuAYKKMlJEnKGf4IrURQ8i9kg4I+qreJiFPQiLArD7kHncGIPNdvIa4qxkb
	 i4JGUpm/MpwNuUvXBhyarm4QvyLdn2CRv5acrTRU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726189AbfAZR7P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 26 Jan 2019 12:59:15 -0500
Received: from mail.kernel.org ([198.145.29.99]:60256 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726089AbfAZR7P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 26 Jan 2019 12:59:15 -0500
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id ADF212184C;
        Sat, 26 Jan 2019 17:59:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1548525554;
        bh=usTGDW7vA49jM6scQlaSGxneW8X7HuIVnkyGGrx+FAg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=IR5T/xn2XzeXhHtevWEsf5Y9bsR86Bw074ewxSnuZ8SYTjR2sQKKKxoyZ9u7E8dYC
         Yt1e459t6ovy020H+UzXZ94Xef81zxzw54LM1k1Wy5uA9mEDTcaJHU6fymUGk3i2Q7
         zd8dlDhs91jWFbm0vLYB6TCCQK1NKOEa0k7vwwAQ=
Date:   Sat, 26 Jan 2019 12:59:12 -0500
From:   Sasha Levin <sashal@kernel.org>
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "trondmy@hammerspace.com" <trondmy@hammerspace.com>,
        "Chuck.Lever@oracle.com" <Chuck.Lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Message-ID: <20190126175912.GB30183@sasha-vm>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
 <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
 <56cb3117bdea296892bab4f798d9c84666157afc.camel@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <56cb3117bdea296892bab4f798d9c84666157afc.camel@netapp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 25, 2019 at 07:13:27PM +0000, Schumaker, Anna wrote:
>On Thu, 2019-01-24 at 19:58 +0000, Trond Myklebust wrote:
>> On Thu, 2019-01-24 at 11:32 -0600, Jason L Tibbitts III wrote:
>> > I could use some help figuring out the cause of some serious NFS
>> > client
>> > issues I'm having with the 4.20.3 kernel which I did not see under
>> > 4.19.15.
>> >
>> > I have a network of about 130 desktops (plus a bunch of other
>> > machines,
>> > VMs and the like) running Fedora 29 connecting to six NFS servers
>> > running CentOS 7.6 (with the heavily patched vendor kernel
>> > 3.10.0-957.1.3).  All machines involved are x86_64.  We use
>> > kerberized
>> > NFS4 with generally sec=krb5i.  The exports are generally made with
>> > "(rw,async,sec=krb5i:krb5p)".
>> >
>> > Since I booted those clients into 4.20.3 I've started seeing
>> > processes
>> > getting stuck in the D state.  The system itself will seem OK (except
>> > for the high load average) as long as I don't touch the hung NFS
>> > mount.
>> > Nothing was logged to dmesg or to the journal.  So far booting back
>> > into
>> > the 4.19.15 kernel has cleared up the problem.  I cannot yet
>> > reproduce
>> > this on demand; I've tried but it is probably related to some
>> > specific
>> > usage pattern.
>> >
>> > Has anyone else seen issues like this?  Can anyone help me to get
>> > more
>> > useful information that might point to the problem?  I still haven't
>> > learned how to debug NFS issues properly.  And if there's a stress
>> > test
>> > tool I could easily run that might help to reproduce the issue, I'd
>> > be
>> > happy to run it.
>> >
>> > I note that 4.20.4 is out; I see one sunrpc fix which I guess could
>> > be
>> > related (sunrpc: handle ENOMEM in rpcb_getport_async) but the systems
>> > involved have plenty of free memory so I doubt that's it.  I'll
>> > certainly try it anyway.
>> >
>> > Various package versions:
>> > kernel-4.20.3-200.fc29.x86_64 (the problematic kernel)
>> > kernel-4.19.15-300.fc29.x86_64 (the functional kernel)
>> > nfs-utils-2.3.3-1.rc2.fc29.x86_64
>> > gssproxy-0.8.0-6.fc29.x86_64
>> > krb5-libs-1.16.1-25.fc29.i686
>> >
>> > Thanks in advance for any help or advice,
>> >
>> >  - J<
>>
>> Commit deaa5c96c2f7 ("SUNRPC: Address Kerberos performance/behavior
>> regression") was supposed to be marked for stable as a fix. Chuck &
>> Anna?
>
>Looks like I missed that, sorry!
>
>Stable folks, can you please backport deaa5c96c2f7 ("SUNRPC: Address Kerberos
>performance/behavior regression") to v4.20?

Queued for 4.20, thank you.

--
Thanks,
Sasha
