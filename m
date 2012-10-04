Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:34241 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab2JDEPZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2012 00:15:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only server?
Date: Wed, 3 Oct 2012 21:15:16 -0700
Message-Id: <11D4587E-7739-4D31-836D-D63177D13302@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Unfortunately our corporate e-mail server lost your e-mail from yesterday.  I read it last night and was going to reply this morning, but it was gone from my mailbox.  I'm not sure how to preserve the thread structure at this point.

I'm OK with the nfsmount.conf() changes, and the addition of IPv6 syntax to the clientaddr= option.

>> The protocol and protocol family the NFS client uses to transmit requests to the NFS server for this mount point.  For example, udp selects UDP over IPv4, while tcp6 selects TCP over IPv6.  If an NFS server has both an IPv4 and an IPv6 address, using a specific netid forces the use of IPv4 or IPv6 networking to communicate with that server.
> 
> I still don't like that last sentence.

Can you say why?

While that sentence could be made more precise, this is one of the key reasons NFS with netids works the way it does.  Dual-stack NFS servers will be pervasive for some time to come.

Other comments:

  o "rdma6" is not supported, and should not be explicitly listed.

  o "mountproto=rdma[6]" is not supported.

  o We discourage the use of UDP with NFSv4 (in fact it may no longer be supported).  The NFSv4 proto= language should not list "udp" or "udp6."

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

