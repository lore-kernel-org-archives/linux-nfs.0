Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:41119 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752771AbeEVUqA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 16:46:00 -0400
Received: by mail-ua0-f173.google.com with SMTP id a3-v6so13252057uad.8
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 13:46:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
 <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 22 May 2018 16:45:59 -0400
Message-ID: <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
Subject: Re: question: re-try of operations in PNFS
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 4:34 PM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
> Hi Olga,
>
> we saw similar issues with early version of RHEL6 kernels, but this was fixed in the later version.
> and it's possible now to set timeout with
>
> dataserver_timeo and dataserver_retrans
>
> bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1175413
>
> Which which kernel do you observe it?

Upstream kernel. But I'm arguing that there shouldn't be a need to
specify a dataserver_timeo because it shouldn't timeout at all just
like MDS operations.

Also curiously, "man nfs" doesn't list "datasever_timeo" option and
when I try to use it on a RHEL7.4 machine it says incorrect option.
Also grep thru the upstream kernel code for "dataserver_timeo" is
empty too.

>
> Regards,
>    Tigran.
>
> ----- Original Message -----
>> From: "Olga Kornievskaia" <aglo@umich.edu>
>> To: "linux-nfs" <linux-nfs@vger.kernel.org>
>> Sent: Thursday, May 17, 2018 10:43:34 PM
>> Subject: question: re-try of operations in PNFS
>
>> Hi Trond,
>>
>> Is there a reason why an rpc connection to the DS is set to timeout
>> requests instead of waiting until the reply from the server ? Requests
>> to DS timeout in 10sec and are resent to MDS.
>>
>> Thank you.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
