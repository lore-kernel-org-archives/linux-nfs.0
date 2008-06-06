From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Results of a Robustness Regression tests and Performances campaign
 on linux-2.6.25-rc6-CITI_NFS4_ALL-1
Date: Fri, 06 Jun 2008 11:15:55 +0200
Message-ID: <4849004B.2010406@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: nfsv4-request@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:35565 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbYFFJRN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2008 05:17:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
The results of a Robustness Regression tests and Performances campaign 
on linux-2.6.25-rc6 plus
the linux-2.6.25-rc6-CITI_NFS4_ALL-1 path are available at : 
http://nfsv4.bullopensource.org/
Those results include kerberos flavors krb5, krb5i, krb5p on Intel 
x86_64 machines.

I needed also to add a patch found at http://lkml.org/lkml/2008/2/29/443
to fix an the infinite loop in generic_file_splice_read() we can see
with nfsv4 when nfsd looping.

Best regards

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 

