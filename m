From: David Warren <warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Subject: [NFS] nfsd hangs 2.6.28 through 2.6.28.7
Date: Mon, 02 Mar 2009 16:06:23 -0800
Message-ID: <49AC747F.6010001@atmos.washington.edu>
Reply-To: warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030507070307050100080500"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44628 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbZCCAHD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2009 19:07:03 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LeI9z-0002Sw-36
	for linux-nfs@vger.kernel.org; Tue, 03 Mar 2009 11:06:59 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030507070307050100080500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We are seeing nfsd getting stuck in d wait at boot time. The fix seems 
to be stopping in single user mode prior to nfs starting, renaming 
/var/lib/nfs/v4recovery/ and making a new one, then letting the system 
continue. When it boots and hangs, all processes that touch 
/var/lib/nfs/v4recovery/ go into D-wait. However, if you rename it and 
let it boot you can look in the old directory. Any ideas what could be 
happening?
Also, is there any documentation on the files in 
/var/lib/nfs/v4recovery/? We would like to possibly be able to decode 
the names.

--------------030507070307050100080500
Content-Type: text/x-vcard; charset=utf-8;
 name="warren.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="warren.vcf"

begin:vcard
fn:David Warren
n:Warren;David
org:Atmospheric Sciences
adr:Dept of Atmospheric Sciences, Box 351640;;University of Washington;Seattle;WA;98195-1640;USA
email;internet:warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
title:Software Engineer
tel;work:206 543-0945
url:http://www.atmos.washington.edu
version:2.1
end:vcard


--------------030507070307050100080500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
--------------030507070307050100080500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--------------030507070307050100080500--


