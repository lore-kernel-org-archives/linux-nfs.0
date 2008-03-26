From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: 2.6.25-rc6-CITI_NFS4_ALL-1 connectathon suite testdir error
Date: Wed, 26 Mar 2008 14:56:52 +0100
Message-ID: <47EA5624.3030905@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:45200 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbYCZNxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Mar 2008 09:53:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Running 2.6.25-rc6-CITI_NFS4_ALL-1 on two Intel X86_64 bi-ways machines as
client and server, get the following error with the runtest (-s) of the special
tests of the connectathon suite when running it with several other robustness
tests (fsx,iozone,fssb,fss_stress) in the same time:

 Second check for lost reply on non-idempotent requests
 testing 50 idempotencies in directory "testdir"
 rmdir 1: Directory not empty
 special tests failed


It is similar to the bug#150 <http://bugzilla.linux-nfs.org/show_bug.cgi?id=150> found with 2.6.23-rc9-CITI_NFS4_ALL-1
Bug:  http://bugzilla.linux-nfs.org/show_bug.cgi?id=150  
which was closed since.  


So I created a new one:
http://bugzilla.linux-nfs.org/show_bug.cgi?id=162


Best Regards

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 

