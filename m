From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] re-exporting NFS-mounted dir over NFS
Date: Thu, 05 Jun 2008 07:47:35 -0400
Message-ID: <4847D257.5020406@redhat.com>
References: <4846A272.8040206@infineon.com> <4846AAB3.9070005@redhat.com> <4847871A.5000206@infineon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Martin Schuster (IFKL IT OS DSM CD)" <Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755580AbYFELri (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 07:47:38 -0400
In-Reply-To: <4847871A.5000206-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Martin Schuster (IFKL IT OS DSM CD) wrote:
> Thanks for your thoughts about this.
>
> Peter Staubach wrote:
>   
>> Is the real goal to be able to export the files using krb5
>> authentication or the use of NFSv4?
>>
>>     
> Both, I fear.
>
>   
>> If the former, then why not just export the files from the
>> NetApp using Kerberos?
>>
>> If the latter, then I suspect that it won't provide much, if
>> any, benefit.  It would still be limited to the NFSv3 semantics
>> of the file system.
>>
>>     
> The current NFS4-support in NetApps OnTap is afaik quite new,
> so our filer administrator doesn't want to enable it in the
> near future; he prefers waiting until the issues that are likely
> to come up are solved before allowing it on a productive machine.
>
> But mounting directly from the filer using NFS3+Kerberos would
> allow the following attack vector, as the clients are in an
> unsecure network (i.e. could get root access on their machines):
>  User mounts an directory using his Kerberos-credentials
>  User gets root, then changes w/o password to another user
>  User can now read the files of that other user, as the NFS3-server
>      doesn't check the permissions
>
> (at least, that's how I understood the difference between NFS3
>  and NFS4 -- please correct me if I'm wrong)
>
>   

Ahh, no.  All versions of the NFS servers check permissions on each
and every file access.  Even NFSv2.  NFSv3 and NFSv4 support an
ACCESS protocol operation which allows the client to ask the server
for which file access permissions that the user would be allowed to
have.

When a file system is exported using krb5, then all file accesses
must be made with the right kerberos credential or access will be
denied.  The attack that you described, while working for AUTH_SYS,
does not work for RPCSEC_GSS with krb5, no matter which version of
the NFS protocol that you are using.


> So my question still is: Is re-exporting an NFS-mount technically
> impossible, or does it just need some coding to get it working?

It may be technically possible, in some situations, but is not
something that is always possible or has ever been supported.
It could easily be used to thwart security.  A compromised
client, which was allowed access to file systems from the server,
could then re-export those file systems to other clients which
should not have been allowed access.

----

The bottom line is that 1) I don't think that the NFSv4
implementation from NetApp is as bad as feared and 2) that
using NFSv3 with krb5 should be as secure as NFSv4 with krb5.
Give either or both a shot.  I think that you will be pleasantly
surprised.

       ps
