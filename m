Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:33451 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751462Ab2A3Hyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 02:54:46 -0500
Message-ID: <4F264AE1.5050600@st.com>
Date: Mon, 30 Jan 2012 07:46:41 +0000
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Reply-To: srinivas.kandagatla@st.com
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com, bharrosh@panasas.com, linux@razik.name
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min
 max delays.
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com> <EBFEB6A8-4943-4D9E-9139-73D14ACB32DD@oracle.com> <4F225BED.7000005@st.com> <20120127123426.GA3089@umich.edu>
In-Reply-To: <20120127123426.GA3089@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:
> I hate timeouts.  Isn't there some way to wait until the interface is up
> before attempting the mount?
>   
I think mount waits till ipconfig is finished, however the actual link
may not be up at that time(in cases of static ip's).
Waiting for link to become UP can have a adverse side-effect of waiting
forever in cases where cable isn't connected or n/w is not reachable....

retry is the only best option at this moment...





