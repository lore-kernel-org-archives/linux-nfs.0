Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:36617 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751575AbeEVVBK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 17:01:10 -0400
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [131.169.56.164])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id D37392804E7
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 23:01:08 +0200 (CEST)
Date: Tue, 22 May 2018 23:01:08 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1719906626.7570776.1527022868136.JavaMail.zimbra@desy.de>
In-Reply-To: <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com> <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de> <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
Subject: Re: question: re-try of operations in PNFS
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Agree, there shouldn't be an extra option for that and probably fresher kernels have dropped
that option. If I recall correctly, the options was there to protect client from pnfs bugs. E.g.
fall back to MDS if it thinks that something went wrong and client happy.

I haven't seen that problem for quite some time. However on modern kernels (and RHEL 7) we prefer
to use flexfiles pnfs layout. One of the reasons is the option to avoid io through mds.

I will try to reproduce it.

Regards,
   Tigran.

----- Original Message -----
> From: "Olga Kornievskaia" <aglo@umich.edu>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Tuesday, May 22, 2018 10:45:59 PM
> Subject: Re: question: re-try of operations in PNFS

> On Tue, May 22, 2018 at 4:34 PM, Mkrtchyan, Tigran
> <tigran.mkrtchyan@desy.de> wrote:
>> Hi Olga,
>>
>> we saw similar issues with early version of RHEL6 kernels, but this was fixed in
>> the later version.
>> and it's possible now to set timeout with
>>
>> dataserver_timeo and dataserver_retrans
>>
>> bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1175413
>>
>> Which which kernel do you observe it?
> 
> Upstream kernel. But I'm arguing that there shouldn't be a need to
> specify a dataserver_timeo because it shouldn't timeout at all just
> like MDS operations.
> 
> Also curiously, "man nfs" doesn't list "datasever_timeo" option and
> when I try to use it on a RHEL7.4 machine it says incorrect option.
> Also grep thru the upstream kernel code for "dataserver_timeo" is
> empty too.
> 
>>
>> Regards,
>>    Tigran.
>>
>> ----- Original Message -----
>>> From: "Olga Kornievskaia" <aglo@umich.edu>
>>> To: "linux-nfs" <linux-nfs@vger.kernel.org>
>>> Sent: Thursday, May 17, 2018 10:43:34 PM
>>> Subject: question: re-try of operations in PNFS
>>
>>> Hi Trond,
>>>
>>> Is there a reason why an rpc connection to the DS is set to timeout
>>> requests instead of waiting until the reply from the server ? Requests
>>> to DS timeout in 10sec and are resent to MDS.
>>>
>>> Thank you.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
