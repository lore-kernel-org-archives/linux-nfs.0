Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44453 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754631Ab0FJG0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 02:26:35 -0400
Message-ID: <4C108598.7020602@panasas.com>
Date: Thu, 10 Jun 2010 09:26:32 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 13/24] pnfs_submit: read path changeover
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>	<1275970761-31806-2-git-send-email-iisaman@netapp.com>	<1275970761-31806-3-git-send-email-iisaman@netapp.com>	<1275970761-31806-4-git-send-email-iisaman@netapp.com>	<1275970761-31806-5-git-send-email-iisaman@netapp.com>	<1275970761-31806-6-git-send-email-iisaman@netapp.com>	<1275970761-31806-7-git-send-email-iisaman@netapp.com>	<1275970761-31806-8-git-send-email-iisaman@netapp.com>	<1275970761-31806-9-git-send-email-iisaman@netapp.com>	<1275970761-31806-10-git-send-email-iisaman@netapp.com>	<1275970761-31806-11-git-send-email-iisaman@netapp.com>	<1275970761-31806-12-git-send-email-iisaman@netapp.com>	<1275970761-31806-13-git-send-email-iisaman@netapp.com>	<1275970761-31806-14-git-send-email-iisaman@netapp.com>	<4C0FE936.2090901@panasas.com>	<AANLkTilecdPbSOJCDkGYH-X25gcZB-1fmBmU9mEpFO_y@mail.gmail.com>	<4C0FEDE2.4080506@panasas.com> <AANLkTim_AH3NwVm0K9fUySaupmGw6gMUYsB3JhUhvIwK@mail.gmail.com>
In-Reply-To: <AANLkTim_AH3NwVm0K9fUySaupmGw6gMUYsB3JhUhvIwK@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2010 10:46 PM, Fred Isaman wrote:
>>>>>  static inline enum pnfs_try_status
>>>>>  pnfs_try_to_read_data(struct nfs_read_data *data,
>>>>>                     const struct rpc_call_ops *call_ops)
>>>>
>>>> Don't think this needs to be inline, whats the point?
>>>>
>>>
>>> The point is that it is in the header file, not a c file.
>>>
>>
>> That's what I meant. Why is it in the header file. Why not
>> in .c file and declared.
>>
> 
> To make it easy to ifdef out if CONFIG_NFS_V4_1 is not set.
> 
> Fred
> 

It's not easier, just:

#ifdef CONFIG_NFS_V4_1
enum pnfs_try_status
pnfs_try_to_read_data(struct nfs_read_data *data,
                     const struct rpc_call_ops *call_ops); /* declaration */
#else
static inline enum pnfs_try_status
pnfs_try_to_read_data(struct nfs_read_data *data,
                     const struct rpc_call_ops *call_ops) /* Empty inline */
{
	return ...;
}
#endif

We do that everywhere. Should also here
Boaz

>>> Fred
>>>
>>
>> (-Bz
>>

