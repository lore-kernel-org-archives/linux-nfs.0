Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:41271 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751154Ab2AZI64 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 03:58:56 -0500
Message-ID: <4F2113FF.9080407@st.com>
Date: Thu, 26 Jan 2012 08:51:12 +0000
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Reply-To: srinivas.kandagatla@st.com
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com> <20120125154539.GA20734@umich.edu> <4F21071B.4070000@st.com> <4F2110DA.7060603@panasas.com>
In-Reply-To: <4F2110DA.7060603@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
> On 01/26/2012 09:56 AM, Srinivas KANDAGATLA wrote:
>   
>> Jim Rees wrote:
>>     
>>> Srinivas KANDAGATLA wrote:
>>>
>>>   From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>>   
>>>   This patch adds mountretry kernel parameter for nfs root mount.
>>>   mount retry indicates the number of times nfs root mount attempts to be
>>>   made before giving up. If this option is not specified, the default
>>>   value of 3 retries is used.
>>>
>>> This has already been fixed in commit 43717c7d, "NFS: Retry mounting
>>> NFSROOT".  The retry count is fixed at 5.  Is there some reason you think
>>> the retry count should be configurable?
>>>   
>>>       
>> Thanks for pointing to the fixed commit. I did realize soon after
>> sending this patch to mailing list.
>>
>> Only reason I can think of having retry count configurable is, an
>> arbitrary number(3 or 5 or n) of retry count may not be enough to
>> address all the use cases.
>> So, I think the user should be given a chance to configure the retry
>> count if he wish to, either timeout quickly and try the succession
>> root-mount or If he wish to keep kernel trying very harder till he gets
>> the NFS root mount successful.
>>
>>     
>
> I agree. Specially if there is no "succession root-mount" setup then user
> can specify a very large count.
>
> Is there some delay between retries. So not to burn 100% power?
>
>   
An nfs root mount attempt timeouts in about 3 sec's and in commit
43717c7d, "NFS: Retry mounting NFSROOT" each retry has additional sleep
which gives sufficient delay between retries.
>> Thanks,
>> srini
>>     
>
> Thanks
> Boaz
>
>   
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     
>
>   

