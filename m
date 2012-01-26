Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:57654 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751262Ab2AZOna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 09:43:30 -0500
Message-ID: <4F2164BC.3020102@st.com>
Date: Thu, 26 Jan 2012 14:35:40 +0000
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Reply-To: srinivas.kandagatla@st.com
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com> <20120125154539.GA20734@umich.edu> <4F21071B.4070000@st.com> <4F2110DA.7060603@panasas.com> <4F2113FF.9080407@st.com> <4F213437.5020802@panasas.com>
In-Reply-To: <4F213437.5020802@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,
Thankyou for your feedback on my patch.
 Am going to re-send the rebased patch in different email-thread with
few other updates to existing nfs-retry code.

Thanks
srini
Boaz Harrosh wrote:
> On 01/26/2012 10:51 AM, Srinivas KANDAGATLA wrote:
>   
>> An nfs root mount attempt timeouts in about 3 sec's and in commit
>> 43717c7d, "NFS: Retry mounting NFSROOT" each retry has additional sleep
>> which gives sufficient delay between retries.
>>     
>
> Grate thanks. Make perfect sense
>
>   
>>>> Thanks,
>>>> srini
>>>>     
>>>>         
>
> Thanks
> Boaz
>   

