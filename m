Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vps4.riden.org.uk ([78.47.247.49]:54486 "EHLO vps4.riden.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825Ab2BITAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 14:00:43 -0500
Received: from [10.210.58.112] (unknown [213.52.196.70])
	by vps4.riden.org.uk (Postfix) with ESMTPSA id 09E5C20267
	for <linux-nfs@vger.kernel.org>; Thu,  9 Feb 2012 18:53:26 +0000 (GMT)
Date: Thu, 9 Feb 2012 18:57:05 +0000 (GMT)
From: Don Riden <don@riden.org.uk>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
In-Reply-To: <4F2EB471.9060508@leicester.ac.uk>
Message-ID: <alpine.LNX.2.00.1202091707390.25543@localhost.localdomain>
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com> <4F2D9A0E.6010503@leicester.ac.uk> <4F2E4B50.5040701@steve-ss.com> <20120205141611.GA12826@umich.edu> <4F2EB471.9060508@leicester.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> Thanks, the problem isn't getting NFS with Kerberos to work in general, it's 
> with AD as the KDC. It seems that NFS still only accepts DES encrypted 
> Kerberos tickets, and these are specifically disabled in Windows Server 2008 
> R2.

I've recently managed to get a Linux Kerberized NFS server working
using an Active Directory 2008 R2 domain controller as a KDC (using
arcfour-hmac and aes256-cts-hmac-sha1-96).

It's reasonably fiddly and took quite a lot of tweaking to get right.

A short summary of the AD specific side of our configuration:

For hosts with Samba 3. We join them to the domain with 'net ads join' and
create NFS principals with 'net ads keytab'.

For hosts without Samba (the vast majority of hosts). We use ksetpw (an old Solaris utility to
generate AES/arcfour principals). I believe that Microsoft has a similar
utility called ktpass.exe but I've never tested it.

I'm happy to provide more details of the domain joining process offlist or summarise in another
email if there is interest.

In the computer Active Directory account we set the :

UserPrincpalName: host/fqdn@DNS_DOMAIN
ServicePrincipalName: host/fqdn and nfs/fqdn
DNSDomainName: fqdn
MSDS-SupportedEncryptionTypes: 0x1C

One caveat. I've observed the following behaviour on RHEL5 and RHEL6 (it may
have changed):

In AD (as far as I'm aware) you can only obtain a TGT from a 
principal matching the UserPrincpalName of the account.  On startup rpc.gssd
obtains a TGT. If you've generated both 'nfs/*' and 'host/*' 
principals in your keytab rpc.gssd will prefer the nfs principal.
This won't work if your UserPrincipalName in AD is 'host/*'.  My workaround in the
past has been to change the search order in the nfs-utils source code (putting the 
host principal first). Using a UPN of nfs/fqdn@DNS_DOMAIN may also work.

One issue that caused me difficulty was configuring the Kerberized NFS
server on Linux. Specifically - clients could mount the filesystem
without issue but when a user attempted to access the mount they got
'permission denied'.

Looking at the NFS requests on the wire I noticed that the GSS tokens
were around 2500 bytes in size. Further research indicated that this is the
result of Microsoft adding a 'Privilege Attribute Certificate' to service
tickets.

Setting the UserAccountControl parameter in AD on the NFS server to
'0x2000000' (NO_AUTH_DATA_REQUIRED) reduced the size of this token to
  about 500 bytes and resolved the issue.

Our NFS clients are mostly RHEL6 and RHEL5 with a few Gentoo boxes running
nfs-utils 1.2.5 and kernel 3.2.1 . All seem to work fine with the above configuration.

On the server side we've tested RHEL6 and Gentoo.

Hopefully that is of some help.

I'm surprised by the lack of documentation available on using Kerberised NFS with AD. I 
would have thought that it would be a fairly common configuration?

Since it's taken me a while to put the pieces together I'll try and come up with some  more
  comprehensive documentation in the near future.

Cheers


Don
