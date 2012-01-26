Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:49184 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751382Ab2AZIEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 03:04:09 -0500
Message-ID: <4F21071B.4070000@st.com>
Date: Thu, 26 Jan 2012 07:56:11 +0000
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Reply-To: srinivas.kandagatla@st.com
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com> <20120125154539.GA20734@umich.edu>
In-Reply-To: <20120125154539.GA20734@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:
> Srinivas KANDAGATLA wrote:
>
>   From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>   
>   This patch adds mountretry kernel parameter for nfs root mount.
>   mount retry indicates the number of times nfs root mount attempts to be
>   made before giving up. If this option is not specified, the default
>   value of 3 retries is used.
>
> This has already been fixed in commit 43717c7d, "NFS: Retry mounting
> NFSROOT".  The retry count is fixed at 5.  Is there some reason you think
> the retry count should be configurable?
>   
Thanks for pointing to the fixed commit. I did realize soon after
sending this patch to mailing list.

Only reason I can think of having retry count configurable is, an
arbitrary number(3 or 5 or n) of retry count may not be enough to
address all the use cases.
So, I think the user should be given a chance to configure the retry
count if he wish to, either timeout quickly and try the succession
root-mount or If he wish to keep kernel trying very harder till he gets
the NFS root mount successful.

Thanks,
srini
