Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.apple.com ([17.151.62.25]:50059 "EHLO
	mail-in2.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751058AbcFATAu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2016 15:00:50 -0400
Received: from [17.115.111.245] (unknown [17.115.111.245])
 by nwk-mmpp-sz07.apple.com
 (Oracle Communications Messaging Server 7.0.5.35.0 64bit (built Mar 31 2015))
 with ESMTPSA id <0O83004OLW4CEB50@nwk-mmpp-sz07.apple.com> for
 linux-nfs@vger.kernel.org; Wed, 01 Jun 2016 11:45:48 -0700 (PDT)
From: Blake Golliher <bgolliher@apple.com>
Content-type: text/plain; charset=utf-8
Subject: NFS client side failover
Message-id: <AEFEE2E4-0F50-44EA-9C33-EC64A7AA6E59@apple.com>
Date: Wed, 01 Jun 2016 11:45:48 -0700
To: linux-nfs@vger.kernel.org
MIME-version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi! 

Hopefully a simple question.  Is there any work in making the linux nfs client able to survive a nfs server failover to another IP?  Meaning, I have an NFS server, on a node called ‘cheetah', and it’s HA side is 'puma', and a client named 'lizard’.  If lizard has an established mount on ‘cheetah’, then cheetah suffers some event, and puma takes over it’s storage, but the IP changes, can lizard try it’s IO to the new IP?  Assuming the fsid, data in the filesystem, export permissions are all fine, the only change is the IP the client is talking to goes away, but there is a new IP it could use.

Is there any work in a client failover like that?  nfsv4.1 or pnfs anything like that?

Thanks!

-Blake



