Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44894 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab2AYTFG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 14:05:06 -0500
Message-ID: <4F20524C.6030704@panasas.com>
Date: Wed, 25 Jan 2012 21:04:44 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jim Rees <rees@umich.edu>,
        Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
        <linux-nfs@vger.kernel.org>, <akpm@linux-foundation.org>,
        <mingo@redhat.com>, <neilb@suse.de>, <stuart.menefy@st.com>
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com> <4F202BD4.5020400@panasas.com> <20120125183200.GA26907@umich.edu> <F96642BB-3C49-4E70-BFE9-E7549CDEDB55@oracle.com>
In-Reply-To: <F96642BB-3C49-4E70-BFE9-E7549CDEDB55@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/25/2012 08:52 PM, Chuck Lever wrote:
> 
> 
>>  I always thought that was inconsistent. With an hard mount NFS
>>  will never give up and will retry for ever freezing all IOers until
>>  the server came back. Only with root-mount it gives up.
> 
> Not true, user space mount can also give up. See nfs(5), the retry=
> option. This is not NFS I/O we're talking about here, there is no
> risk of data corruption. So "hard" versus "soft" does not apply.
> 

OK I see your point

>>  Please explain what is the benefits of giving up at all. Can a machine
>>  be at all usable without it's root? 
> 
> There are several different root file system options built into the
> kernel. NFSROOT is but one. Each is tried in succession. If NFSROOT
> never gives up, then the others that follow it are never tried.
> 

OK I did not know that. Thanks for the explanation, good to know.
In the few times I tried NFSROOT I never setup an alternative.

I wish that in the case that the NFSROOT is the only option it would
keep trying.

When the Kernel does not find it's root it panics, I know. If the sata
disk is not there, it's not there. But with NFSROOT there is a good chance it
will come up soon. (We all saw the same power outage and the server is slow
to boot)

I just think it could be more user friendly that's all

Thanks
Boaz
