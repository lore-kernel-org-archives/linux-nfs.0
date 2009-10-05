From: Milos Jakovljevic <milos_sd-wj0mSnlwsj31P9xLtpHBDw@public.gmane.org>
Subject: nfs server and client doesn't work in 2.6.32-rcX kernels
Date: Mon, 05 Oct 2009 14:54:18 +0200
Message-ID: <1254747258.7129.7.camel@c2d-desktop>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.s481.sureserver.com ([64.14.68.216]:54277 "EHLO
	s481.sureserver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932402AbZJENBi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2009 09:01:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I compiled 2.6.32-rc3 (and rc1(2) before that) on one PC. On the other
PC I have 2.6.31 kernel.


NFS-Server problem:

When I try to restart nfs-kernel-server service it says that my kernel
doesn't have nfs-server support. That is when nfs-server support is
compiled as a module, but when I compile it as part of a kernel it
works.

NFS client problem:

I tried to compile it as part of the kernel and as module, but I alweys
have the same situation:

I try to mount nfs share that is on other PC (that has 2.6.31 kernel),
and it seems it mounts ok. But when I go to that directory and do: "ls",
I get errors saying: "input/output error" for every directory that nfs
share has in it.

I don't know if the problem is in compitability with older kernels or
with "nfs-kernel-server and nfs-common" packages in Ubuntu 9.04.



