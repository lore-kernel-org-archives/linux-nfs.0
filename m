Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:23852 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab2AYSxE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 13:53:04 -0500
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root mount.
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120125183200.GA26907@umich.edu>
Date: Wed, 25 Jan 2012 13:52:47 -0500
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
        linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com
Message-Id: <F96642BB-3C49-4E70-BFE9-E7549CDEDB55@oracle.com>
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com> <4F202BD4.5020400@panasas.com> <20120125183200.GA26907@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 25, 2012, at 1:32 PM, Jim Rees wrote:

> Boaz Harrosh wrote:
> 
>  On 01/25/2012 04:50 PM, Srinivas KANDAGATLA wrote:
>> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>> 
>> This patch adds mountretry kernel parameter for nfs root mount.
>> mount retry indicates the number of times nfs root mount attempts to be
>> made before giving up. If this option is not specified, the default
>> value of 3 retries is used.

Is there a reason 3 is not an adequate fixed setting?  For some reason I don't seem to have this patch in my inbox.

>  If the system is set to have root on NFS. And the root is not found
>  what does it do? does it Just bums out with a recovery console?

No.  It tries the next root file system type.

>  So what better options does it have other then retry for ever. die?

If no root file systems are available, then yes, the kernel panics.  This has been the case for a very very long time.

>  I always thought that was inconsistent. With an hard mount NFS
>  will never give up and will retry for ever freezing all IOers until
>  the server came back. Only with root-mount it gives up.

Not true, user space mount can also give up.  See nfs(5), the retry= option.  This is not NFS I/O we're talking about here, there is no risk of data corruption.  So "hard" versus "soft" does not apply.

>  Please explain what is the benefits of giving up at all. Can a machine
>  be at all usable without it's root? 

There are several different root file system options built into the kernel.  NFSROOT is but one.  Each is tried in succession.  If NFSROOT never gives up, then the others that follow it are never tried.

> Doesn't grub have some fallback logic in case the given kernel/root fails?
> Also, don't you want some indication that it's not working other than just a
> blank screen?

The kernel is running at this point, grub is well out of the picture.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




