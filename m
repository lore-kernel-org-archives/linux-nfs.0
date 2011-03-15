From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] RPC: return task->tk_status from rpc_wait_for_completion_task()
 in case of successfull task completion
Date: Tue, 15 Mar 2011 20:36:38 +0300
Message-ID: <4D7FA3A6.4000305@parallels.com>
References: <20110315141951.16564.72417.stgit@localhost6.localdomain6> <1300199215.14093.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"skinsbursky@openvz.org" <skinsbursky@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22293 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758188Ab1CORhe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2011 13:37:34 -0400
In-Reply-To: <1300199215.14093.1.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

15.03.2011 17:26, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 2011-03-15 at 17:20 +0300, Stanislav Kinsbursky wrote:
>> Some NFS and NLM routines doesn't check RPC task tk_status if
>> rpc_wait_for_completion_task() returned 0 but have to.
>
> Examples please. I'm not aware of any such cases.
>
> Cheers
>     Trond
>

You are right. I was confused with different logic for NSFv4, NLM and N=
=46Sv3.
Drop the patch.
Sorry.

--=20
Best regards,
Stanislav Kinsbursky
