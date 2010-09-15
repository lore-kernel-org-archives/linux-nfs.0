Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:7724 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724Ab0IOMyd convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 08:54:33 -0400
From: "Assarsson, Emil" <Emil.Assarsson@sonyericsson.com>
To: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Date: Wed, 15 Sep 2010 14:44:31 +0200
Subject: NFSv4 with Winbind: successfull mount but no user access
Message-ID: <2BF070A7A2375D46BA1B6087F8D5DCB678B5D18A01@seldmbx01.corpusers.net>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm currently trying to iron out a procedure how to setup NFSv4 with Winbind.

We use a setup with:
Ubuntu Lucid (10.04)
Windows A 2003
Winbind

I have successfully configured NFSv4 with MIT KRB5 KDC but with AD there is still some problems...

By default rpc.gssd tries to login with a principal name like host/client01.test.net. The AD KDC rejects this and tells me that it does not exist. It seems to me that AD makes a difference between userPrincipalName and servicePrincipalName when an AS-REQ is done. The userPrincipalName on my client is CLIENT01\$ and I can kinit with this name.

rpc.gssd have an "-n" option that allows me to do a kinit before I start this daemon:
# kinit -Rk CLIENT01\$
# rpc.gssd -n
I can mount (krb5i) with this setup and I can get access to the share 
*** But only if I use the same Kerberos machine credentials ***
I have tried to get any useful information with Wireshark and verbose logging, but all seems to be successful (KRB and NFS packages); The user gets an access denied message.

I have two theories about this:
1. Rpc.gssd with the -n option behaves different and I need to make it use the correct keytab by modifying the code (maybe with a new option like "-P CLIENT\$@TEST.NET").
2. Rpc.svcgssd needs to be extended in the same way with an -n option

Does this seem likely? 


Best regards

Emil Assarsson
Sony Ericsson Mobile Communications AB

"The information in this email, and attachment(s) thereto, is strictly confidential and may be legally privileged. It is intended solely for the named recipient(s), and access to this e-mail, or any attachment(s) thereto, by anyone else is unauthorized. Violations hereof may result in legal actions. Any attachment(s) to this e-mail has been checked for viruses, but please rely on your own virus-checker and procedures. If you contact us by e-mail, we will store your name and address to facilitate communications in the matter concerned. If you do not consent to us storing your name and address for above stated purpose, please notify the sender promptly. Also, if you are not the intended recipient please inform the sender by replying to this transmission, and delete the e-mail, its attachment(s), and any copies of it without, disclosing it."


