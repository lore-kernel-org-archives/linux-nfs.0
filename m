Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:36719 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170Ab1DUG66 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2011 02:58:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id DD9E42B8020
	for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2011 08:58:57 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.73])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id ZztsGGUfWHqW for <linux-nfs@vger.kernel.org>;
	Thu, 21 Apr 2011 08:58:57 +0200 (CEST)
Received: from pc-rsmits.dto.tudelft.nl (pc-rsmits.dto.tudelft.nl [131.180.97.81])
	by mx2.tudelft.nl (Postfix) with ESMTP id 2D0EE2B801D
	for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2011 08:58:57 +0200 (CEST)
Message-ID: <4DAFD5B1.9060004@tudelft.nl>
Date: Thu, 21 Apr 2011 08:58:57 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: gssd mounts not working
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,
We are having problems with our gssd nfs mounts. I will explain our 
situation.

Our clients are running SLED 11 SP1.
Our server is a Netapp filer with Ontap 7.3.3P4.

We provide NFS exported directory's with krb5 security.

Our KDC is a Windows 2003 and 2008 Active Directory.

If we use nfs-client-1.2.1-8.1 everything works as expected.

But if we upgrade to (any) newer client, all gssd mounts fail. Now there 
is a bugreport on Novell Bugzilla about this : 
https://bugzilla.novell.com/show_bug.cgi?id=614293#c7

Apperantly if the nfs client is compiled with --disable-tirpc , the 
ticket size from the AD is to big ?

On our Redhat server we do not have these problems. There we are running 
: nfs-utils-1.2.2-7

Is there an explanation for these problems ? How can i find out if a 
client has been compiled with specific options. There is no nfs devel 
package for suse.

Greetings .. Richard Smits
