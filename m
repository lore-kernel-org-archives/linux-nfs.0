Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rhebok.le.ac.uk ([143.210.16.38]:46430 "EHLO rhebok.le.ac.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450Ab2GRK4i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 06:56:38 -0400
Received: from host-13-77.it.le.ac.uk ([143.210.13.77]:64021)
	by rhebok.le.ac.uk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <liam.gretton@leicester.ac.uk>)
	id 1SrRvp-0007DK-74
	for linux-nfs@vger.kernel.org; Wed, 18 Jul 2012 11:56:37 +0100
Message-ID: <50069666.9030602@leicester.ac.uk>
Date: Wed, 18 Jul 2012 11:56:38 +0100
From: Liam Gretton <liam.gretton@leicester.ac.uk>
MIME-Version: 1.0
To: Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfs4_setfacl and principals with spaces
References: <50066EC5.6040804@leicester.ac.uk>
In-Reply-To: <50066EC5.6040804@leicester.ac.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A bit more Googling and I found a git repository at 
<git://linux-nfs.org/~bfields/nfs4-acl-tools.git>.

Assuming this really is the latest version I've now fixed the problem 
and will submit a patch to Bruce Fields.

If anyone thinks that's the wrong source for the ACL tools please let me 
know.

-- 
Liam Gretton                                    liam.gretton@le.ac.uk
HPC Architect                                 http://www.le.ac.uk/its
IT Services                                   Tel: +44 (0)116 2522254
University of Leicester, University Road
Leicestershire LE1 7RH, United Kingdom


