Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-3.desy.de ([131.169.56.86]:54073 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755158Ab1DURAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2011 13:00:52 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 2A77A14B1
	for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2011 18:32:08 +0200 (MEST)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 0CED8148C
	for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2011 18:32:07 +0200 (MEST)
Message-ID: <4DB05BB3.8080706@desy.de>
Date: Thu, 21 Apr 2011 18:30:43 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Steve Dickson <SteveD@redhat.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: pNFS kernel for Fedora 15
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Steve et. al.

it looks like kernel fails to correctly work with
rpc.gssd if some of kernel modules statically
compiled:

BAD (pnfs kernel from Steve):
CONFIG_SUNRPC_GSS=m
CONFIG_RPCSEC_GSS_KRB5=y

in messages:
[  537.544188] gss_create: Pseudoflavor 390003 not found!
[  537.544236] RPC: Couldn't create auth handle (flavor 390003)


GOOD (fedora native kernel or my own build):
CONFIG_SUNRPC_GSS=m
CONFIG_RPCSEC_GSS_KRB5=m

Steve, could you build new kernel with CONFIG_RPCSEC_GSS_KRB5=m ?


BTW, there was a similar issue with nfsd discussed last couple of days.
http://www.spinics.net/lists/linux-nfs/msg20617.html


Thanks
    Tigran.


