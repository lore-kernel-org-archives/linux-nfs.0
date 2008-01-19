From: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Sat, 19 Jan 2008 13:35:37 +0100
Message-ID: <4791EE99.3030802@abinetworks.biz>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns4.abinetworks.biz ([216.218.212.66]:49744 "EHLO
	ns4.abinetworks.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbYASMie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Jan 2008 07:38:34 -0500
In-Reply-To: <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck,

As you requested i have finally found out that the problem was 
introduced in 2.6.22 (2.6.21.7 works, after 2.6.21.7 theres 2.6.22)

I have also examined the changeslogs: 2.6.22 introduce a certain number 
of patches into NFS client. Many of them are yours and Trond's.

Pls can you help with this ?

TIA

Gianluca
