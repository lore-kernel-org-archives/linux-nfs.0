Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm2-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.248]:27709 "HELO
	nm2-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755459Ab1EGPvM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 May 2011 11:51:12 -0400
Message-ID: <585464.69250.qm@web111704.mail.gq1.yahoo.com>
Date: Sat, 7 May 2011 08:45:34 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: file is run on server but not on client
To: nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
The problem is when I run a command on the server, it works fine but when I run that from a client, it doesn't find that file.
ar@server:~/s1/src$ ls -l run
-rwxr-xr-x 1 ar users 2573621 2011-05-07 19:47 run
ar@server:~/s1/src$ ./run
Usage: ./run paramfile outfile format iotrace synthgen?

You can see that it ask for usage which shows the binary file works

However in the client:

ar@client:~/s1/src$ ls -l run
-rwxr-xr-x 1 ar users 2573621 2011-05-07 15:17 run
ar@client:~/s1/src$ ./run
-bash: ./run: No such file or directory


the file property is the same but I don't know why it does not find that (!)
// Naderan *Mahmood;
