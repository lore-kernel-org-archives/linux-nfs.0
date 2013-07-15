Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.22]:57419 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618Ab3GOQyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 12:54:33 -0400
Message-ID: <51E42943.8040001@gmx.de>
Date: Mon, 15 Jul 2013 18:54:27 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "user-mode-linux-devel@lists.sourceforge.net"
	<user-mode-linux-devel@lists.sourceforge.net>
Subject: Re: sunrpc/clnt.c: BUG kmalloc-256 (Not tainted): Poison overwritten
References: <51E25B20.7030906@gmx.de> <1373857286.3181.1.camel@leira.trondhjem.org>
In-Reply-To: <1373857286.3181.1.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/15/2013 05:01 AM, Myklebust, Trond wrote:
> On Sun, 2013-07-14 at 10:02 +0200, Toralf Förster wrote:
>> This bisected commit produces at a 32 bit user mode linux guest the attached BUG :
>>
>> commit eeee245268c951262b861bc1be4e9dc812352499
>> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date:   Wed Jul 10 15:33:01 2013 -0400
>>
>>     SUNRPC: Fix a deadlock in rpc_client_register()
>>
>>     Commit 384816051ca9125cd54750e59c780c2a2655fa4f (SUNRPC: fix races on
>>     PipeFS MOUNT notifications) introduces a regression when we call
>>     rpc_setup_pipedir() with RPCSEC_GSS as the auth flavour.
>>
>>     By calling rpcauth_create() while holding the sn->pipefs_sb_lock, we
>>     end up deadlocking in gss_pipes_dentries_create_net().
>>     Fix is to register the client and release the mutex before calling
>>     rpcauth_create().
>>
>>     Reported-by: Weston Andros Adamson <dros@netapp.com>
>>     Tested-by: Weston Andros Adamson <dros@netapp.com>
>>     Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
>>     Cc: <stable@vger.kernel.org> # : 3848160: SUNRPC: fix races on PipeFS MOUNT
>>     Cc: <stable@vger.kernel.org> # : e73f4cc: SUNRPC: split client creation
>>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>
>>
>>
>>
>>
>>
>> 2013-07-13T22:09:07.000+02:00 trinity sm-notify[1042]: Version 1.2.6 starting
>> 2013-07-13T22:09:07.000+02:00 trinity sm-notify[1042]: Backgrounding to notify hosts...
>> 2013-07-13T22:09:07.000+02:00 trinity sm-notify[1043]: Running as root.  chown /var/lib/nfs to choose different user
>> 2013-07-13T22:09:10.000+02:00 trinity mount[1047]: mount to NFS server 'n22stab4' failed: No route to host, retrying
>> 2013-07-13T22:09:11.000+02:00 trinity dhcpcd[971]: eth0: sending IPv6 Router Solicitation
>> 2013-07-13T22:09:11.000+02:00 trinity dhcpcd[971]: eth0: no IPv6 Routers available
>> 2013-07-13T22:09:13.000+02:00 trinity mount[1048]: mount to NFS server 'n22stab4' failed: No route to host, retrying
>> 2013-07-13T22:09:13.647+02:00 trinity kernel: =============================================================================
>> 2013-07-13T22:09:13.647+02:00 trinity kernel: BUG kmalloc-256 (Not tainted): Poison overwritten
>> 2013-07-13T22:09:13.647+02:00 trinity kernel: -----------------------------------------------------------------------------

<snip>

>> 2013-07-13T22:09:13.647+02:00 trinity kernel:

> Does the attached patch fix the problem?

Yes.

And it solves another related problem too : a soft lookup of CPU0 during
shutdown of the UML guest

:-)



-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
