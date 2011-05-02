From: Dennis Jacobfeuerborn <dennisml@conversis.de>
Subject: Re: rpc.statd is not running but is required
Date: Mon, 02 May 2011 12:00:46 +0200
Message-ID: <4DBE80CE.8070406@conversis.de>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com> <20110502183547.7e9f1295@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Mahmood Naderan <nt_mahmood@yahoo.com>,
	nfs <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.conversis.de ([213.203.219.181]:51279 "EHLO
	mail4.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab1EBK30 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 06:29:26 -0400
In-Reply-To: <20110502183547.7e9f1295-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/02/2011 10:35 AM, NeilBrown wrote:
> On Mon, 2 May 2011 00:59:01 -0700 (PDT) Mahmood Naderan
> <nt_mahmood@yahoo.com>  wrote:
>
>> Hi,
>> I have setup NFS and I checked every thing with documents and manual.
>> After the client boots up, it says:
>>
>>
>> mount.nfs: rpc.statd is not running but is required for remote locking.
>> mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
>> mountall: mount /opt [1000] terminated with status 32
>
> mount tried to run  /usr/sbin/start-statd and it failed for some reason.
> What is in /usr/sbin/start-statd ??
> What happens if you run it directly?
> What happens if you just run  /usr/sbin/rpc.statd??
>

Have you tried checking if the /etc/init.d/nfslock service is enabled and 
running?

Regards,
   Dennis
