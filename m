Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eriks.xs4all.nl ([83.163.214.71]:41447 "EHLO eriks.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754482Ab2L3M64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 30 Dec 2012 07:58:56 -0500
Received: from nemesis.slagter.name (nemesis [10.1.1.1])
	by nemesis.slagter.name (Postfix) with ESMTP id 2E4874E0080
	for <linux-nfs@vger.kernel.org>; Sun, 30 Dec 2012 13:53:19 +0100 (CET)
Received: from artemis.slagter.name (artemis [IPv6:2001:980:5fef:1::7])
	by nemesis.slagter.name (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Sun, 30 Dec 2012 13:53:18 +0100 (CET)
Received: from [10.1.1.5] (eos.ipv4.slagter.name [10.1.1.5])
	by artemis.slagter.name (Postfix) with ESMTP id 51E233930A0A
	for <linux-nfs@vger.kernel.org>; Sun, 30 Dec 2012 13:53:18 +0100 (CET)
Message-ID: <50E0393E.7040204@slagter.name>
Date: Sun, 30 Dec 2012 13:53:18 +0100
From: Erik Slagter <erik@slagter.name>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS client large rsize/wsize (tcp?) problems
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello All,

I am almost complete NOOB on this matter, so please be gentle ;-) I do 
believe there is some sort of problem inside the NFS code though.

Background: I have:
  - linux server x86_64, vanilla kernel 3.6.7 sharing a few exports
  - several set-top-boxes running linux, arch is mipsel32, they're 
almost vanilla, but they have prioprietary closed source drivers for the 
DVB frontends:
    * MaxDigital XP1000, kernel 3.5.1
    * DMM DM8000, kernel 3.2.0
    * VU+ Ultimo, kernel 3.1.1

These all suffer from the same problem. When they have a share mounted 
with default parameters, using tcp, they crash sooner or later, notably 
after heavy share access. The dm8000 has it's gui killed by the 
OOM-killer whilst the xp1000 and the ultimo simply lock up.

The OOM-killer reports it needs blocks of 128k (probably for NFS, but it 
doesn't say it), but can't find them. For the other stb'es it's not 
clear as they lock up.

I've "discovered" a few interesting things:
  - adding swap to the dm8000 makes the problem almost go away, although 
without NFS it definitely doesn't need swap, ever.
  - when I ran my laptop (x86_64!) with a slightly older kernel (2.6.35 
iirc) from a rescue cd, at a certain point I also got nasty dmesg 
reports and the "dd" proces got stuck in D state, this was reproducable 
over reboots.
  - all clients work flawlessly (over extended perdiods of time) if 
mounted using udp and smaller rsize/wsize values (max 32k). Tcp seems to 
work as well, as long as the size values are kept under 32k.
  - the x86_64 laptop also worked fine when mounted this way
  - so apparently it's not a stb/mipsel32/proprietary driver issue.
  - stb's running older kernels (notably 2.6.18) don't suffer from this 
problem

Can please anyone enlighten me? I can't find similar reports other than 
from fellow stb users.

Thanks!
