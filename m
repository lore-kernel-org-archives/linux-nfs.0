Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from master.debian.org ([70.103.162.29]:58447 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab0FBLf6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2010 07:35:58 -0400
Date: Wed, 2 Jun 2010 21:25:21 +1000
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Cc: Guillem Jover <guillem@debian.org>, 583435@bugs.debian.org
Subject: Re: Bug#583435: rpcbind: Insecure handling of state files
Message-ID: <20100602112520.GA22639@master.debian.org>
References: <20100527170908.GA14298@gaara.hadrons.org>
 <20100601120907.GA23357@gaara.hadrons.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20100601120907.GA23357@gaara.hadrons.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 01, 2010 at 02:09:07PM +0200, Guillem Jover wrote:
>Hi!
>
>On Thu, 2010-05-27 at 19:09:08 +0200, Guillem Jover wrote:
>>Package: rpcbind
>>Version: 0.2.0-4
>>Severity: serious
>>Tags: security
>
>>The rpcbind daemon, which runs as root, uses /tmp/portmap.xdr and
>>/tmp/rpcbind.xdr for doing warm starts as what seems to be a way to
>>preserve state between invokations. It parses (through libtirpc) and
>>removes them on start. It creates them before exiting.
>>
>>So first off, *any* user can craft those two files before the daemon
>>has started for the first time, which the daemon will parse. This
>>might be ok, depending on the checks done on parse, I'd still be very
>>wary of letting a user be able to craft such files at will.
>
>It seems to be doing no checks whatsoever. A simple test I performed at
>the time of filing this report, but didn't seem to have any obvious
>consequence, shows this which I noticed later on:
>
>,---
>gaara:~# /etc/init.d/rpcbind start
>Starting rpcbind daemon....
>gaara:~# ps axuOp|egrep '(^USER|[r]pcbind)'
>USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
>root     23424  0.0  0.0  18768   704 ?        Ss   13:53   0:00 /sbin/rpcbind -w
>gaara:~# /etc/init.d/rpcbind stop
>Stopping rpcbind daemon....
>gaara:~# dd if=/dev/urandom of=/tmp/rpcbind.xdr bs=1024 count=1
>1+0 records in
>1+0 records out
>1024 bytes (1,0 kB) copied, 0,000861307 s, 1,2 MB/s
>gaara:~# /etc/init.d/rpcbind start
>Starting rpcbind daemon....
>gaara:~# ps axuOp|egrep '(^USER|[r]pcbind)'
>USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
>root     23440  0.0  0.0 4008972  772 ?        Ss   13:54   0:00 /sbin/rpcbind -w
>`---
>
>The first start is a normal clean invokation, the second one is using
>the crafted file. See how it has allocated almost 4 GiB. Disregard though,
>me running all this as root, a user would be able to craft those files as
>long as they were not already in /tmp.
>
>thanks,
>guillem

I'm sending this bug report to the linux-nfs mailing list.

The original bug report is at http://bugs.debian.org/583435

Thank you.
