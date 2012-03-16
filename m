Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:42314 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422764Ab2CPPMZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 11:12:25 -0400
Received: by wibhj6 with SMTP id hj6so1009922wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 08:12:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331857679.24392.9.camel@lade.trondhjem.org>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
	<1331836850-5195-8-git-send-email-andros@netapp.com>
	<1331857679.24392.9.camel@lade.trondhjem.org>
Date: Fri, 16 Mar 2012 11:12:23 -0400
Message-ID: <CAHVgHyVvKPgD6hCqAH3k6Da=U1mkYYZ+fGr+99yWTGT04Hb6nA@mail.gmail.com>
Subject: Re: [PATCH Version 1 07/11] NFSv4.1 Check invalid deviceid upon slot
 table waitq wakeup
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 15, 2012 at 8:27 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2012-03-15 at 14:40 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Register a new filelayout DS rpc_action callback for sleeping on the fore
>> channel slot table waitq.  Avoid any additional RPC FSM states
>> (such as timeout) when waking up to an invalid deviceid and reset
>> the task for io to the MDS.
>
> Why can't you simply put this call to filelayout_write_sleepon_cb in
> filelayout_write_prepare (before calling nfs41_setup_sequence())?

I guess I can. Will do.

-->Andy

>
> Since nothing is going to change the task->tk_action if
> nfs41_setup_sequence() puts you to sleep, what value does the callback
> add?

> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
