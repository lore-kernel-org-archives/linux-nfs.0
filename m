Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:53954 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab1IMJni convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 05:43:38 -0400
Received: from smtp01.web.de  ( [172.20.0.243])
	by fmmailgate03.web.de (Postfix) with ESMTP id C9C5319942895
	for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 11:43:37 +0200 (CEST)
Received: from [80.66.224.98] (helo=PC5280)
	by smtp01.web.de with esmtp (WEB.DE 4.110 #2)
	id 1R3PWj-0005ZL-00
	for linux-nfs@vger.kernel.org; Tue, 13 Sep 2011 11:43:37 +0200
From: "Tim" <supertimothy@web.de>
To: <linux-nfs@vger.kernel.org>
Subject: nfsv4 and gracetime / leasetime grace_period
Date: Tue, 13 Sep 2011 11:43:37 +0200
Message-ID: <000801cc71f9$9cc45650$d64d02f0$@web.de>
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all!

First, just a question to make clear, with nfsv4 rpc.statd and nfslock are
not needed ? The Clients are not notified with sm-notify in case of a reboot
- is this correct?
But how does the notification of clients work with nfsv4?


The problem I can see is the same as described here:
http://www.digipedia.pl/usenet/thread/18978/22974/

So we have different values:

/proc/fs/nfsd/nfsv4gracetime
/proc/fs/nfsd/nfsv4leasetime
/proc/sys/fs/nfs/nlm_grace_period

If I set graceteime and grace_period to a low value, I get a faster
failover. But what do they stand for and do I need nfsv4leasetime to ?
If I set them all to 10 seconds, could that be "dangerous" (assume the
server can handle the additional load)?

I guess there isn't an easy way to delete all the locks on serverside and
explicitely tell the clients: Hey, the server has rebooted, please get a new
lock for all your files. :-)
I just would like to make failover a bit faster. 

Thanks a lot!
Tim

