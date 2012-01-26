Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60841 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab2AZLJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 06:09:04 -0500
Message-ID: <4F213437.5020802@panasas.com>
Date: Thu, 26 Jan 2012 13:08:39 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <srinivas.kandagatla@st.com>
CC: Jim Rees <rees@umich.edu>, <linux-nfs@vger.kernel.org>,
        <akpm@linux-foundation.org>, <mingo@redhat.com>, <neilb@suse.de>,
        <stuart.menefy@st.com>
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com> <20120125154539.GA20734@umich.edu> <4F21071B.4070000@st.com> <4F2110DA.7060603@panasas.com> <4F2113FF.9080407@st.com>
In-Reply-To: <4F2113FF.9080407@st.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/26/2012 10:51 AM, Srinivas KANDAGATLA wrote:
> An nfs root mount attempt timeouts in about 3 sec's and in commit
> 43717c7d, "NFS: Retry mounting NFSROOT" each retry has additional sleep
> which gives sufficient delay between retries.

Grate thanks. Make perfect sense

>>> Thanks,
>>> srini
>>>     
>>

Thanks
Boaz
