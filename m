Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:47990 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932785Ab1KJQLZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 11:11:25 -0500
Received: from [192.168.6.103] (bovic.calvaedi.com [192.168.6.103])
	(authenticated (0 bits))
	by oceanic.CalvaEDI.COM (8.11.1-20030923/8.11.1/6.32) with ESMTP id pAAGBN405763
	(using TLSv1/SSLv3 with cipher RC4-MD5 (128 bits) verified NO)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 17:11:23 +0100 (CET)
Message-ID: <4EBBF7AB.8030907@Calva.COM>
Date: Thu, 10 Nov 2011 17:11:23 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [BUG] nfs4 client loops printing "Error: state manager encountered
 RPCSEC_GSS session expired" if kerberos ticket expires
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We mount user home directories (using automount) from an nfs4 server 
with sec=krb5.

Using older kernels (2.6.32 for example) when the user ticket expires 
attempts to access the mount get EPERM.  This is no big deal, the 
workstation is probably in the screensaver so the user enters her 
password, a new ticket is granted and everything carries on.

At some point (before or after 2.6.39) this behaviour changed.

Now attempts to access the mount point hang and an endless stream of:

Error: state manager encountered RPCSEC_GSS session expired against NFSv4 server xxxx


messages is printed to the kernel log.  The user doesn't get prompted 
for a password and can only get a new ticket by moving to a text console 
and logging in again (which unblocks things).

(This is Debian bug 
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=648155 and Ubuntu bug 
https://bugs.launchpad.net/ubuntu/+bug/794112 ).

The client is Debian Sid, with kernel 3.1.0-rc10 on a Dell core i5 based 
Optiplex 390.  (The same problem occurs in the standard Debian 3.0 kernel).

Linux cretic 3.1.0-rc10 #1 SMP Thu Nov 10 11:45:46 CET 2011 x86_64 GNU/Linux

The server is Debian Squeeze, kernel 2.6.32.

What should I be trying to do to debug this?


