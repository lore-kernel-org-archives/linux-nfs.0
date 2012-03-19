Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26171 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757396Ab2CSWMZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 18:12:25 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        Andy Adamson <androsadamson@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 1 07/11] NFSv4.1 Check invalid deviceid upon
 slot table waitq wakeup
Date: Mon, 19 Mar 2012 22:12:23 +0000
Message-ID: <8EFC917B-F078-4935-A308-0008F9065759@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
 <1331836850-5195-8-git-send-email-andros@netapp.com>
 <1331857679.24392.9.camel@lade.trondhjem.org>
 <CAHVgHyVvKPgD6hCqAH3k6Da=U1mkYYZ+fGr+99yWTGT04Hb6nA@mail.gmail.com>
 <110373F8-CDA5-416C-85D3-F31775667D03@netapp.com>
 <1332193750.17930.14.camel@lade.trondhjem.org>
In-Reply-To: <1332193750.17930.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 19, 2012, at 5:49 PM, Myklebust, Trond wrote:

> On Mon, 2012-03-19 at 21:32 +0000, Adamson, Andy wrote:
>> On Mar 16, 2012, at 11:12 AM, Andy Adamson wrote:
>> 
>>> On Thu, Mar 15, 2012 at 8:27 PM, Myklebust, Trond
>>> <Trond.Myklebust@netapp.com> wrote:
>>>> On Thu, 2012-03-15 at 14:40 -0400, andros@netapp.com wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>>> 
>>>>> Register a new filelayout DS rpc_action callback for sleeping on the fore
>>>>> channel slot table waitq.  Avoid any additional RPC FSM states
>>>>> (such as timeout) when waking up to an invalid deviceid and reset
>>>>> the task for io to the MDS.
>>>> 
>>>> Why can't you simply put this call to filelayout_write_sleepon_cb in
>>>> filelayout_write_prepare (before calling nfs41_setup_sequence())?
>>> 
>>> I guess I can. Will do.
>> 
>> Actually, I that won't work.
>> 
>>> 
>>> -->Andy
>>> 
>>>> 
>>>> Since nothing is going to change the task->tk_action if
>>>> nfs41_setup_sequence() puts you to sleep, what value does the callback
>>>> add?
>> 
>> The rpc_action remains rpc_call_prepare. But! We want the tasks coming off the failed DS fore channel slot table queue to be redirected to the MDS nfs_XXX_prepare, not the filelayout_xxx_prepare.
> 
> So? Calling rpc_restart_call_prepare() will have exactly the same effect
> if you do it within filelayout_xxx_prepare as it will within a callback.

Sigh. For some reason I removed the call to rpc_restart_call_prepare. 

Got it. 

-->Andy
> 
>> Note that filelayout_reset_read and filelayout_reset_write set the data->ds_clp to NULL which makes the call to nfs41_setup_sequence() in filelayout_write/read_prepare Oops…..
>> 
>> So, I'll keep this patch as is.
> 
> NACK. Adding a parameter to the sequence arguments is way too ugly a
> hack. This has nothing to do with the sequence op.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

