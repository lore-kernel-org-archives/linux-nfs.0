Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51408 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbaLIIRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 03:17:04 -0500
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Tue, 09 Dec 2014 09:16:59 +0100
From: =?UTF-8?Q?David_H=C3=A4rdeman?= <david@hardeman.nu>
Cc: SteveD@redhat.com, timo.teras@iki.fi
Message-ID: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

it seems that the "rework access to /proc/net/rpc" patchset removed 
dynamic buffers in favour of static, fixed size, buffers. That seems 
like a step backwards to me?

At least the readline() function could be implemented using read/write 
(instead of fread/fwrite) and a dynamic buffer...no?

//David

