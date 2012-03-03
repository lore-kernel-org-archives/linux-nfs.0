Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:54936 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab2CCMVX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Mar 2012 07:21:23 -0500
Received: from [192.168.1.14] (217-70-247-131.dragonet.es [217.70.247.131] (may be forged))
	(authenticated bits=0)
	by partagas.dragonet.es (8.12.11/8.12.11) with ESMTP id q23CLQQt005989
	for <linux-nfs@vger.kernel.org>; Sat, 3 Mar 2012 13:21:32 +0100
Message-ID: <4F520CB4.1030203@steve-ss.com>
Date: Sat, 03 Mar 2012 13:21:08 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfs3 lockd: cannot monitor errors
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi
We recently switched to nfs3 from nfs4 and now we're getting lots of 
lockd errors. We can remove the error by mounting with:
  -o local_lock=posix

We had to switch to be able to use the posix acl we had set on the share.

What problems may we face by setting the local_lock?
Thanks,
Steve

