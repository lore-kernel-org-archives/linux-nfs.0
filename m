Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40307 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993Ab1INGrD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 02:47:03 -0400
Received: by wyh22 with SMTP id 22so1341008wyh.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 23:47:02 -0700 (PDT)
Message-ID: <4E704DE2.1030308@tonian.com>
Date: Wed, 14 Sep 2011 08:46:58 +0200
From: Benny Halevy <bhalevy@tonian.com>
To: tao.peng@emc.com
CC: Trond.Myklebust@netapp.com, bergwolf@gmail.com, gusev.vitaliy@nexenta.com,
        gusev.vitaliy@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>  <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>  <1315348373.19556.22.camel@lade.trondhjem.org>  <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>  <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>  <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>  <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED4C8@SACMVEXC2-PRD.hq.netapp.com>  <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>  <1315592430.17611.15.camel@lade.trondhjem.org>  <4E6B0E48.7050208@tonian.com>  <CA+a=Yy5fMHPcSU4EoSo1uiOUCfi8vjRVPAjEYGZ+M00CwZ8Z9g@mail.gmail.com>  <4E6E6C3B.2040605@tonian.com> <1315861851.8350.11.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805C3299F96@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3299F96@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-13 10:09, tao.peng@emc.com wrote:
> Hi, Trond,
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
>> On Behalf Of Trond Myklebust
>> Sent: Tuesday, September 13, 2011 5:11 AM
>> To: Benny Halevy
>> Cc: Peng Tao; Peng, Tao; gusev.vitaliy@nexenta.com; gusev.vitaliy@gmail.com;
>> linux-nfs@vger.kernel.org
>> Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
>>
>> On Mon, 2011-09-12 at 13:31 -0700, Benny Halevy wrote:
>>> On 2011-09-12 07:56, Peng Tao wrote:
>>>>> The layout segments are not really in use while in LAYOUTCOMMIT.
>>>>> We only need to get the stateid right with respect to concurrent layout recalls.
>>>> LAYOUTCOMMIT takes lseg reference to mark them as in use so that
>>>> layoutrecall cannot free them.
>>>>
>>>
>>> And if layoutrecall would have freed layout segments during layoutcommit,
>>> what is your specific concern?
>>
>> That layoutcommit is supposed to return NFS4ERR_BAD_LAYOUT in that case
>> according to section 18.42.3 of RFC5661. I can't find anything in the
>> errata that changes that requirement.
> Do you mean that if client sends layoutcommit at the same time as server sends layoutrecall for overlapped range, then
> server must reject layoutcommit with NFS4ERR_BADLAYOUT when receiving layoutcommit?
> 
> RFC5661 section 18.42.3 says:
>    If the layout identified in the arguments does not exist, the error
>    NFS4ERR_BADLAYOUT is returned.  The layout being committed may also
>    be rejected if it does not correspond to an existing layout with an
>    iomode of LAYOUTIOMODE4_RW.
> 
> IMHO, in the above case, server cannot decide if the layout exists until client returns response to layoutrecall.

Right, unless the server revokes the layout, but then there are also other consequences
like SEQ4_STATUS_RECALLABLE_STATE_REVOKED.

Benny

> But I can't find
> any requirement in RFC5661 that server must wait for layoutrecall's response before processing layoutcommit.
> 
> Thanks,
> Tao
