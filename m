Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm22-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.222]:36133 "HELO
	nm22-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753231Ab1ASSJw convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 13:09:52 -0500
Message-ID: <574433.84174.qm@web111710.mail.gq1.yahoo.com>
Date: Wed, 19 Jan 2011 10:09:49 -0800 (PST)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: high traffic because of loggig
To: nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
In my cluster that /home is shared (from a server and some workers). The problem 
is when I run my job that has some huge log data, the disk access as well as 
network traffic is very high. I want to know is there any way so 
that the worker writes the log locally and at the end, that log is copied from 
worker's internal hdd to server's hdd (/home)?

Hope that I clearly stated the problem.
Thanks, 
// Naderan *Mahmood;


      
