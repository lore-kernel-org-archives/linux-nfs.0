From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Question: why only 8 security flavors per export??
Date: Fri, 04 Dec 2009 13:30:19 -0500
Message-ID: <4B19553B.9090706@RedHat.com>
References: <4B1934A7.90801@RedHat.com> <68742FB7-C923-4219-909F-F47B992584C6@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035AbZLDSaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 13:30:15 -0500
In-Reply-To: <68742FB7-C923-4219-909F-F47B992584C6@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/04/2009 12:08 PM, Andy Adamson wrote:
> 
> 
>> Hello,
>>
>> Why are only 8 (SECFLAVOR_COUNT) security flavors allow
>> per export when 13 security flavors are supported
>> (see flav_map[] in  nfs/exports.c)?
>>
>> I'm trying to create an export that supports all possible
>> security flavors and its erroring out with "mountd: more than
>> 8 security flavors on an export"
> 
> SPKM3 drafts have expired, and the LIPKEY RFC is based on SPKM3 and was
> never implemented. The SPKM3 implementation was used for
> experimentation, but never in production anywhere and should probably be
> removed from the kernel. So in reality, the list of all possible
> security flavors is:
> 
> AUTH_NONE, AUTH_NULL, AUTH_SYS, AUTH_UNIX, krb5, krb5i and krb5p.
> 
Ok... thanks... 

steved.
