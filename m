Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23859 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbbGXOnN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 10:43:13 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] SUNRPC: Fix a backchannel deadlock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AE826EEC-0E23-49C3-B5CF-F25DBEB1A586@oracle.com>
Date: Fri, 24 Jul 2015 10:42:36 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <61786D5B-C758-45E5-B6E2-69F14E3D86F2@oracle.com>
References: <1437597373-19455-1-git-send-email-trond.myklebust@primarydata.com> <0E5E2AA6-6FCF-4A0E-94E3-91A2D529B58B@oracle.com> <CAHQdGtSdvM9J2fmHv5z72q0dtWW_LdOL4-9WsabPz6BFFEj=rg@mail.gmail.com> <AE826EEC-0E23-49C3-B5CF-F25DBEB1A586@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2015, at 5:15 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jul 22, 2015, at 5:14 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> On Wed, Jul 22, 2015 at 4:40 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> Hi Trond-
>>> 
>>> 
>>> On Jul 22, 2015, at 4:36 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>> 
>>>> xprt_alloc_bc_request() cannot call xprt_free_bc_request() without
>>>> deadlocking, since it already holds the xprt->bc_pa_lock.
>>>> 
>>>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>>>> Fixes: 0d2a970d0ae55 ("SUNRPC: Fix a backchannel race")
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> 
>>> That’s exactly what I did as a basic fix, and I can report that
>>> it successfully avoids the deadlock.
>>> 
>>> If xprt_alloc_bc_request() no longer calls xprt_free_bc_request(),
>>> are the accounting changes introduced by 0d2a970d0ae55 still
>>> necessary?
>> 
>> The accounting changes are there to fix the race that Christoph
>> reported in which a valid backchannel request can be rejected by the
>> RPC layer if it happens to come in after the reply to the previous
>> request was sent, but before xprt_free_bc_request has completed. I
>> would therefore expect them still to be needed.
>> 
>> That said, I just noticed that the bc_free_count was being incorrectly
>> maintained. Should be fixed with v2 of the patch series.
> 
> I will get v2 in front of the tester who found this issue.

The v2 fix appears solid. Thanks!


--
Chuck Lever



