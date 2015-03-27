Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atl4mhob04.myregisteredsite.com ([209.17.115.42]:54345 "EHLO
	atl4mhob04.myregisteredsite.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbbC0TA2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 15:00:28 -0400
Received: from mailpod.hostingplatform.com ([10.30.71.204])
	by atl4mhob04.myregisteredsite.com (8.14.4/8.14.4) with ESMTP id t2RJ0Q6G021090
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 15:00:26 -0400
From: "Rupert Dance" <rsdance@soft-forge.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>,
        "'Steve Dickson'" <SteveD@redhat.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com> <5508AC34.3030508@RedHat.com> <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com> <550AE575.4000104@RedHat.com> <003701d06265$b85ce8e0$2916baa0$@soft-forge.com> <55143FAF.7090200@RedHat.com> <02E76CFB-C575-4267-83A9-448CB69AC8C6@oracle.com>
In-Reply-To: <02E76CFB-C575-4267-83A9-448CB69AC8C6@oracle.com>
Subject: RE: Connectathon Issues
Date: Fri, 27 Mar 2015 15:00:20 -0400
Message-ID: <00c601d068c0$46713c20$d353b460$@soft-forge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck,

Here is what the systems are running,

3.10.0-123.el7.x86_64 #1 SMP Thu Sep 11 15:55:14 CDT 2014 x86_64 x86_64
x86_64 GNU/Linux
Scientific Linux release 7.0 (Nitrogen)

Thanks

Rupert

-----Original Message-----
From: Chuck Lever [mailto:chuck.lever@oracle.com] 
Sent: Thursday, March 26, 2015 1:58 PM
To: Steve Dickson
Cc: Rupert Dance; Linux NFS Mailing List
Subject: Re: Connectathon Issues


On Mar 26, 2015, at 12:19 PM, Steve Dickson <SteveD@redhat.com> wrote:

>> There are several other combinations that cause other errors:
>> 
>> 1. The test hangs and no error is reported.  In these cases the 
>> client system MUST be restarted before it becomes usable again. The 
>> server system is restarted to get back to a known good state and 
>> clear the exports before restarting testing
>> 
>> 2. Connectathon Basic test hangs with the client system displaying:
./test5:
>> read and write
> Is it really hung or is it just slow? On the client, use tshark host 
> <server> to see if there is anything going over the wire.

I'm guessing Rupert is using NFS/RDMA. If true, tshark is not going to be
helpful.

Rupert, what is the output of "uname -a" on your systems?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





