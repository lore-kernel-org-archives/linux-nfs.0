Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39975 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbbFHPzh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 11:55:37 -0400
Message-ID: <5575BAEF.4080704@oracle.com>
Date: Mon, 08 Jun 2015 08:55:27 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V3 1/7] nfsd/sunrpc: add a new svc_serv_ops struct
 and move sv_shutdown into it
References: <CAHQdGtQ6NSf2o+Tn=8f0HzECFV3WUOKcPODY-+-RmafUu6Mt7w@mail.gmail.com>
In-Reply-To: <CAHQdGtQ6NSf2o+Tn=8f0HzECFV3WUOKcPODY-+-RmafUu6Mt7w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/08/2015 05:42 AM, Trond Myklebust wrote:
> On Mon, Jun 8, 2015 at 1:21 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
>> sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
> 
> The subject does not need to be duplicated in the body of the email.
> 
>> In later patches we'll need to abstract out more operations on a
>> per-service level, besides sv_shutdown and sv_function.
>>
>> Declare a new svc_serv_ops struct to hold these operations, and move
>> sv_shutdown into this struct.
>>
>> Author: Jeff Layton <jlayton@primarydata.com>
> 
> This should read
> 
> From: Jeff Layton <jlayton@primarydata.com>
> 
> and should be the first line in the body of your email so that 'git'
> can pick it up automatically. See Documentation/SubmittingPatches

Thanks, I will modify and resend these patches.

> Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
