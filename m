From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [NFS] re-exporting NFS-mounted dir over NFS
Date: Thu, 5 Jun 2008 12:08:53 -0400
Message-ID: <76bd70e30806050908l537110a0v89069a37c033fb73@mail.gmail.com>
References: <4846A272.8040206@infineon.com> <4846AAB3.9070005@redhat.com>
	 <4847871A.5000206@infineon.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Martin Schuster (IFKL IT OS DSM CD)" <Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:14176 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763AbYFEQIz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2008 12:08:55 -0400
Received: by wx-out-0506.google.com with SMTP id h29so461434wxd.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2008 09:08:54 -0700 (PDT)
In-Reply-To: <4847871A.5000206-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 5, 2008 at 2:26 AM, Martin Schuster (IFKL IT OS DSM CD)
<Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org> wrote:
> Thanks for your thoughts about this.
>
> Peter Staubach wrote:
>> Is the real goal to be able to export the files using krb5
>> authentication or the use of NFSv4?
>>
> Both, I fear.
>
>> If the former, then why not just export the files from the
>> NetApp using Kerberos?
>>
>> If the latter, then I suspect that it won't provide much, if
>> any, benefit.  It would still be limited to the NFSv3 semantics
>> of the file system.
>>
> The current NFS4-support in NetApps OnTap is afaik quite new,
> so our filer administrator doesn't want to enable it in the
> near future; he prefers waiting until the issues that are likely
> to come up are solved before allowing it on a productive machine.

The NFSv4 server in OnTAP is several years old, actually.  There were
some problems with it in the 6.5 and 7.0 time frame, but if your filer
is running a current OnTAP release (7.2.2, I think, is the most recent
GD release) you should be fine.  The "early adopter period" is long
over for NFSv4 support in OnTAP.

Mounting the filer directly will definitely be more secure (and
perform better) than going through an NFSv3 gateway.  I think Peter
has covered most of the details already.

> So my question still is: Is re-exporting an NFS-mount technically
> impossible, or does it just need some coding to get it working?

Aside from the fact that it is not advisable to do, I don't think it
is technically possible on Linux with the kernel NFS server.
NFS-exportable file systems must have special hooks to construct NFS
file handles from on-disk inodes correctly, and I don't think the
Linux NFS client provides those hooks.  You might have better luck
using the user-space NFS server on your gateway system, but it has
plenty of known issues.

-- 
Chuck Lever
