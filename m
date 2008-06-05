From: "Martin Schuster (IFKL IT OS DSM CD)" <Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Subject: Re: [NFS] re-exporting NFS-mounted dir over NFS
Date: Thu, 5 Jun 2008 08:26:34 +0200
Message-ID: <4847871A.5000206@infineon.com>
References: <4846A272.8040206@infineon.com> <4846AAB3.9070005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.infineon.com ([217.10.60.23]:12437 "EHLO
	smtp2.infineon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbYFEG0m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2008 02:26:42 -0400
In-Reply-To: <4846AAB3.9070005@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for your thoughts about this.

Peter Staubach wrote:
> Is the real goal to be able to export the files using krb5
> authentication or the use of NFSv4?
> 
Both, I fear.

> If the former, then why not just export the files from the
> NetApp using Kerberos?
> 
> If the latter, then I suspect that it won't provide much, if
> any, benefit.  It would still be limited to the NFSv3 semantics
> of the file system.
>
The current NFS4-support in NetApps OnTap is afaik quite new,
so our filer administrator doesn't want to enable it in the
near future; he prefers waiting until the issues that are likely
to come up are solved before allowing it on a productive machine.

But mounting directly from the filer using NFS3+Kerberos would
allow the following attack vector, as the clients are in an
unsecure network (i.e. could get root access on their machines):
 User mounts an directory using his Kerberos-credentials
 User gets root, then changes w/o password to another user
 User can now read the files of that other user, as the NFS3-server
     doesn't check the permissions

(at least, that's how I understood the difference between NFS3
 and NFS4 -- please correct me if I'm wrong)

So my question still is: Is re-exporting an NFS-mount technically
impossible, or does it just need some coding to get it working?

Thanks in advance,
-- 
Infineon Technologies IT-Services GmbH   Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org
Lakeside B05, 9020 Klagenfurt, Austria   Martin Schuster
         FB: LG Klagenfurt, FN 246787y   +43 5 1777 3517
