Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:56269 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab2DYVFW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2012 17:05:22 -0400
Received: from [192.168.1.2] (217-70-247-131.dragonet.es [217.70.247.131] (may be forged))
	(authenticated bits=0)
	by partagas.dragonet.es (8.12.11/8.12.11) with ESMTP id q3PL5fIW023951
	for <linux-nfs@vger.kernel.org>; Wed, 25 Apr 2012 23:05:50 +0200
Message-ID: <4F986760.2000908@steve-ss.com>
Date: Wed, 25 Apr 2012 23:06:40 +0200
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: LOOKUP Reply Error:NFS3ERR_NO_ENT
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi
Without Kerberos, I can rw to the share just fine. With Krb5, I get 
'Permission denied' when I try and write to it. The only error I can see 
on wireshark is:
LOOKUP Reply Error:NFS3ERR_NO_ENT

Any ideas where to start looking?
Cheers,
Steve
