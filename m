Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:58489 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756053Ab1EGToA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 May 2011 15:44:00 -0400
Date: Sat, 7 May 2011 15:43:55 -0400
From: Jim Rees <rees@umich.edu>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>
Subject: Re: file is run on server but not on client
Message-ID: <20110507194355.GA2112@merit.edu>
References: <585464.69250.qm@web111704.mail.gq1.yahoo.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <585464.69250.qm@web111704.mail.gq1.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Mahmood Naderan wrote:

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

This is not an nfs issue.  The client is missing the interpreter for this
file.  If you do "head -1 run" you will see the name of the missing
interpreter.  You also might want to check your timezone settings.
