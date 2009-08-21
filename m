From: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:21:16 -0500
Message-ID: <4A8F0FCC.2080709@sun.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
 <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
 <20090821182418.GE21043@fieldses.org>
 <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
 <20090821200403.GA23529@fieldses.org>
 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
 <1250889345.5700.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-4.Sun.COM ([192.18.98.36]:34653 "EHLO
	brmea-mail-4.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932390AbZHUVVu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 17:21:50 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7LLLpbJ001624
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2009 21:21:51 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOQ00K00WG2MT00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Fri,
 21 Aug 2009 15:21:51 -0600 (MDT)
In-reply-to: <1250889345.5700.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> What is the definition of "recently introduced" here? What is the exact
> commit that introduced the bug in nfs-utils?
>
> The problem is that we're changing the client, and if it turns out that
> every damned Linux server that was installed out there in the past 2
> years displays this bug, then Linus will call 'regression' on us and
> revert the code.
>
> Trond
>
>   

The Linux client and server have well defined behaviors in that they always
will default to AUTH_SYS.

It may not be standard compliant, but everyone and their dog knows it.

Newer servers will not hand out empty lists, and why cause yourself grief
by not handling older servers?
