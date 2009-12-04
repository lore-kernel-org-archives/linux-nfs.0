From: Andy Adamson <andros@netapp.com>
Subject: Re: Question: why only 8 security flavors per export??
Date: Fri, 4 Dec 2009 12:08:30 -0500
Message-ID: <68742FB7-C923-4219-909F-F47B992584C6@netapp.com>
References: <4B1934A7.90801@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1550 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756644AbZLDRIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 12:08:25 -0500
In-Reply-To: <4B1934A7.90801-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> Hello,
>
> Why are only 8 (SECFLAVOR_COUNT) security flavors allow
> per export when 13 security flavors are supported
> (see flav_map[] in  nfs/exports.c)?
>
> I'm trying to create an export that supports all possible
> security flavors and its erroring out with "mountd: more than
> 8 security flavors on an export"

SPKM3 drafts have expired, and the LIPKEY RFC is based on SPKM3 and  
was never implemented. The SPKM3 implementation was used for  
experimentation, but never in production anywhere and should probably  
be removed from the kernel. So in reality, the list of all possible  
security flavors is:

AUTH_NONE, AUTH_NULL, AUTH_SYS, AUTH_UNIX, krb5, krb5i and krb5p.

-->Andy
>
> steved.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

