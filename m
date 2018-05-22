Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:57485 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752718AbeEVUoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 16:44:22 -0400
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [131.169.56.164])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 056FB280063
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 22:34:26 +0200 (CEST)
Date: Tue, 22 May 2018 22:34:25 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de>
In-Reply-To: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
Subject: Re: question: re-try of operations in PNFS
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

we saw similar issues with early version of RHEL6 kernels, but this was fixed in the later version.
and it's possible now to set timeout with

dataserver_timeo and dataserver_retrans

bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1175413

Which which kernel do you observe it?

Regards,
   Tigran.

----- Original Message -----
> From: "Olga Kornievskaia" <aglo@umich.edu>
> To: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Thursday, May 17, 2018 10:43:34 PM
> Subject: question: re-try of operations in PNFS

> Hi Trond,
> 
> Is there a reason why an rpc connection to the DS is set to timeout
> requests instead of waiting until the reply from the server ? Requests
> to DS timeout in 10sec and are resent to MDS.
> 
> Thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
