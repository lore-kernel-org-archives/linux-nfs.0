Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:63026 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaCFTCR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 14:02:17 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so3118373iec.23
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 11:02:16 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140306184847.GA18850@umich.edu>
Date: Thu, 6 Mar 2014 14:02:13 -0500
Cc: Andrew Martin <amartin@xes-inc.com>, bhawley@luminex.com,
        Brown Neil <neilb@suse.de>, linux-nfs-owner@vger.kernel.org,
        linux-nfs@vger.kernel.org
Message-Id: <63E10595-DB6A-4C7E-9C08-BEFF0592F757@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <20140306173632.GA18545@umich.edu> <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com> <20140306184847.GA18850@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 13:48, Jim Rees <rees@umich.edu> wrote:

> Andrew Martin wrote:
> 
>> From: "Jim Rees" <rees@umich.edu>
>> Why would a bunch of blocked apaches cause high load and reboot?
>  What I believe happens is the apache child processes go to serve
>  these requests and then block in uninterruptable sleep. Thus, there
>  are fewer and fewer child processes to handle new incoming requests.
>  Eventually, apache would normally kill said children (e.g after a 
>  child handles a certain number of requests), but it cannot kill them
>  because they are in uninterruptable sleep. As more and more incoming
>  requests are queued (and fewer and fewer child processes are available
>  to serve the requests), the load climbs.
> 
> But Neil says the sleeps should be interruptible, despite what the man page
> says.
> 
> Trond, as far as you know, should a soft mount be interruptible by SIGINT,
> or should it require a SIGKILL?

The ‘TASK_KILLABLE’ state is interruptible by any _fatal_ signal. So if the application uses sigaction() to install a handler for SIGINT, then the RPC call will no longer be interruptible by SIGINT.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

