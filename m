From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Got error -10052 from the server on DESTROY_SESSION. Session
 has 	been destroyed regardless...
Date: Wed, 09 Jun 2010 11:16:28 +0300
Message-ID: <4C0F4DDC.9000107@panasas.com>
References: <4C0E6C37.3040504@panasas.com>	<AANLkTinzsVkmZBAqXxQpBScy71L6DSUlYiRwa_kZAicN@mail.gmail.com>	<4C0E8176.9090406@panasas.com> <AANLkTimF96pcQl53ZaBdpECe-OBP-JX7lw2zZ3S_1UZ5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60399 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752986Ab0FIIQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 04:16:31 -0400
In-Reply-To: <AANLkTimF96pcQl53ZaBdpECe-OBP-JX7lw2zZ3S_1UZ5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2010 08:56 PM, Alexandros Batsakis wrote:
> can you collect lient traces ? They would be more useful.

I'll leave this down for now. I can't reliably reproduce it.
I'm sure it will come up again later. Will do when that comes.

> The error message you see is not fatal, it happens if the RPC is
> killed for some reason (e.g. during umount) or if the request
> timeouts. But this trace wasn't collected at umount time, right ?

No, normal heavy IO (git clone linux)

> Also are these the objects client and server ?
> 

That you never need to ask. Always ;-)
Do you suspect it might be different, because of the no-rpc thing?

> -alexandros
> 

Boaz
