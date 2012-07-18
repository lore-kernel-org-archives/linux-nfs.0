Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rhebok.le.ac.uk ([143.210.16.38]:41557 "EHLO rhebok.le.ac.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902Ab2GRIX1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 04:23:27 -0400
Received: from host-13-77.it.le.ac.uk ([143.210.13.77]:62614)
	by rhebok.le.ac.uk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <liam.gretton@leicester.ac.uk>)
	id 1SrPIG-0005Q3-7o
	for linux-nfs@vger.kernel.org; Wed, 18 Jul 2012 09:07:36 +0100
Message-ID: <50066EC5.6040804@leicester.ac.uk>
Date: Wed, 18 Jul 2012 09:07:33 +0100
From: Liam Gretton <liam.gretton@leicester.ac.uk>
MIME-Version: 1.0
To: Linux NFS <linux-nfs@vger.kernel.org>
Subject: nfs4_setfacl and principals with spaces
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

nfs4_setfacl doesn't seem to be able to cope with spaces in the 
principal's name:

nfs4_setfacl -a A:fdg:"Domain Admins@domain.com":rwaDdxtTnNcCoy file

Scanning ACE string 'A:fdg:Domain' failed.
Failed while inserting ACE(s) (at index 1).

No variation of quoting or escaping seems to be able to work around this 
problem. Is this a known problem or is there a magic way to work around 
it that I haven't worked out?

I'm using 0.3.3 of nfs4-acl-tools as shipped with SLES 11.

If this hasn't been fixed in the whatever the latest version is I'd 
happily do so myself and submit a patch, but I can't find the source 
anywhere. I can only find a reference to a broken git link at 
<http://linux-nfs.org/wiki/index.php/Client_ACL_tools>.

-- 
Liam Gretton                                    liam.gretton@le.ac.uk
HPC Architect                                 http://www.le.ac.uk/its
IT Services                                   Tel: +44 (0)116 2522254
University of Leicester, University Road
Leicestershire LE1 7RH, United Kingdom

