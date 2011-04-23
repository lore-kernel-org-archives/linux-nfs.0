Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738Ab1DWMQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Apr 2011 08:16:50 -0400
Message-ID: <4DB2C32B.7000400@RedHat.com>
Date: Sat, 23 Apr 2011 08:16:43 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Richard Smits <R.Smits@tudelft.nl>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: gssd mounts not working
References: <4DAFD5B1.9060004@tudelft.nl>
In-Reply-To: <4DAFD5B1.9060004@tudelft.nl>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 04/21/2011 02:58 AM, Richard Smits wrote:
> Hello,
> We are having problems with our gssd nfs mounts. I will explain our situation.
> 
> Our clients are running SLED 11 SP1.
> Our server is a Netapp filer with Ontap 7.3.3P4.
> 
> We provide NFS exported directory's with krb5 security.
> 
> Our KDC is a Windows 2003 and 2008 Active Directory.
> 
> If we use nfs-client-1.2.1-8.1 everything works as expected.
> 
> But if we upgrade to (any) newer client, all gssd mounts fail. Now there is a bugreport on Novell Bugzilla about this : https://bugzilla.novell.com/show_bug.cgi?id=614293#c7
> 
> Apperantly if the nfs client is compiled with --disable-tirpc , the ticket size from the AD is to big ?
Yes this problem was fixed in libitrpc with:

commit 599511589ca7ddb3b2eac8d3aa5b0b38be7a7691
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Mar 5 14:27:13 2010 -0500

    libtirpc: allow larger ticket sizes with RPCSEC_GSS


> On our Redhat server we do not have these problems. There we are running : nfs-utils-1.2.2-7
> 
> Is there an explanation for these problems ? How can i find out if a client has been compiled with specific options. There is no nfs devel package for suse.
Good question... I don't think there is way to was to tell how each
binary has been compiled... but doing a ldd `which rpc.gssd` will show
which shared libraries will be used.. If libtirpc.so.1 does not show up 
in that list the you know the rpc.gssd was compile with --disable-tirpc

steved.

