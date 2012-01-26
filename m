Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:49565 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431Ab2AZPOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 10:14:32 -0500
Message-ID: <4F216C11.9070906@st.com>
Date: Thu, 26 Jan 2012 15:06:57 +0000
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Reply-To: srinivas.kandagatla@st.com
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com, chuck.lever@oracle.com,
        bharrosh@panasas.com
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min
 max delays.
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com> <20120126145520.GA10112@umich.edu>
In-Reply-To: <20120126145520.GA10112@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:
> You may want to read the mailing list thread from the earlier patch.  I
> don't remember the details but lowering the panic timeout from 110 to 41
> seconds may re-introduce the problem that patch was trying to solve.  You
> could increase the retry count to compensate.
>   
>From commit  43717c7d, "NFS: Retry mounting NFSROOT" log.
Original problems looks exactly same as the one I encountered.
First operation was an rpcbind request to determine which port the NFS
server was listening on timeout in 2-3 seconds, by this time Switch was
ready. which was then followed by default nfs port 2049 selection at
this time the nfs mount was successful.

In my case the PHY became ready just before the second attempt, same as
LAN switch in the original issue.
I think most of the cases fall in this category.
So there was no delay before this patch except the timeout from rpcbind
was sufficient delay to get the Switch/PHY(in my case) in working state.

I think introduction of timeout actually was not necessary for the
second attempt.

If user want to have more delay than 41 secs, he will be able to
increase the retry count from my mount-retry kernel param patch.

Thanks,
srini
