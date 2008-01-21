From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Mon, 21 Jan 2008 11:55:53 -0500
Message-ID: <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com> <4791EE99.3030802@abinetworks.biz>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55090 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbYAUQ5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 11:57:55 -0500
In-Reply-To: <4791EE99.3030802-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Gianluca-

On Jan 19, 2008, at 7:35 AM, Gianluca Alberici wrote:
> Hello Chuck,
>
> As you requested i have finally found out that the problem was  
> introduced in 2.6.22 (2.6.21.7 works, after 2.6.21.7 theres 2.6.22)
>
> I have also examined the changeslogs: 2.6.22 introduce a certain  
> number of patches into NFS client. Many of them are yours and Trond's.
>
> Pls can you help with this ?


[ I trimmed the Linux kernel mailing list because this is an NFS  
specific problem.  No need to add more noise on lkml. ]

The first thing to do is to capture a network trace during the  
failing operation.  Capturing a trace with a working kernel, and one  
with a failing kernel, would let us see how the behavior changes  
between the two.

To capture a network trace, you can use "tcpdump" on your client:

   sudo tcpdump -s0 -w /tmp/dumpfile hostname-of-server

Substitute the fully-qualified domain name of your server for  
"hostname-of-server".

Try this with a working client and a broken client.  The /tmp/ 
dumpfile will be a binary file.  You can post it on a convenient web  
site, or attach it to e-mail.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



