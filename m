Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p01c12o147.mxlogic.net ([208.65.145.70]:40813 "EHLO
	p01c12o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab0F3VYs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 17:24:48 -0400
Content-Type: text/plain; charset=US-ASCII
Subject: mount - Fedora13 - Nfsv4.1 mode
Date: Wed, 30 Jun 2010 14:15:31 -0700
Message-ID: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com>
From: "Sandeep Joshi" <sjoshi@bluearc.com>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am using  NFS 4.1 client with nfslayoutdriver loaded. (using Fedora 13)
If I try to mount the same directory twice from client. I see two exchange id's
being sent to server. I was expecting only one exchange id. 

Here are the steps that I am executing:

modprobe nfslayoutdriver
mount -t nfs4 -o minorversion=1 <serv-ip-address>:/ /mnt/<dir>
mount -t nfs4 -o minorversion=1 <serv-ip-address>:/ /mnt/<dir>

Is this expected behavior?


regards,

Sandeep

