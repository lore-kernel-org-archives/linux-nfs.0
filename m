From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Mon, 28 Jan 2008 15:54:22 -0500
Message-ID: <12964A18-350B-443F-B15A-D78B3723C89A@oracle.com>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com> <4791EE99.3030802@abinetworks.biz> <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com> <479C744A.6020207@abinetworks.biz>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42697 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbYA1Uyp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 15:54:45 -0500
In-Reply-To: <479C744A.6020207-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Gianluca-

On Jan 27, 2008, at 7:08 AM, Gianluca Alberici wrote:
> Hello Chuck,
>
> i have produced the output you requested using the code i used to  
> show you last time (which simply tries to open(... | O_TRUNC) a  
> file onto the nfs mount and writes "Hello" into it. I simply  
> iterate execution 2 times. The mount is a loop mount on 127.0.0.1
> Since the second execution (the first time it creates the file) you  
> get EINVAL:
>
> FILE CREATION:
>
> hydra:~# tcpdump -s0 -i lo port 2049
> tcpdump: verbose output suppressed, use -v or -vv for full protocol  
> decode
> listening on lo, link-type EN10MB (Ethernet), capture size 65535 bytes
> 12:15:06.306619 IP localhost.251828621 > localhost.nfs: 120 getattr  
> fh Unknown/ 
> 47521E2B0223C100000000000000000000000000000000000000000000000000
> 12:15:06.306666 IP localhost.nfs > localhost.251828621: reply ok 96  
> getattr DIR 40777 ids 0/0 sz 4096
> 12:15:06.306705 IP localhost.268605837 > localhost.nfs: 128 lookup  
> fh Unknown/ 
> 47521E2B0223C100000000000000000000000000000000000000000000000000  
> "test"
> 12:15:06.306752 IP localhost.nfs > localhost.268605837: reply ok 28  
> lookup ERROR: No such file or directory
> 12:15:06.306786 IP localhost.285383053 > localhost.nfs: 160 create  
> fh Unknown/ 
> 47521E2B0223C100000000000000000000000000000000000000000000000000  
> "test"
> 12:15:06.306917 IP localhost.nfs > localhost.285383053: reply ok  
> 128 create fh Unknown/ 
> 48521E2B0323C120000000000000000000000000000000000000000000000000
> 12:15:06.307179 IP localhost.302160269 > localhost.nfs: 144 write  
> fh Unknown/ 
> 48521E2B0323C120000000000000000000000000000000000000000000000000 5  
> (5) bytes @ 0 (0)
> 12:15:06.307283 IP localhost.nfs > localhost.302160269: reply ok 96  
> write

We need to have the raw output of tcpdump.  Please use "-w dumpfile"  
and send the raw output.

>> sudo tcpdump -s0 -w /tmp/dumpfile hostname-of-server


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
