Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bronze.cs.yorku.ca ([130.63.90.34]:44284 "EHLO
	bronze.cs.yorku.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756319Ab0HCPxJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 11:53:09 -0400
Received: from [130.63.86.125] (ident=jas)
	by bronze.cs.yorku.ca with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <jas@cse.yorku.ca>)
	id 1OgJnf-0004vQ-7C
	for linux-nfs@vger.kernel.org; Tue, 03 Aug 2010 11:53:07 -0400
Message-ID: <4C583B63.4050903@cse.yorku.ca>
Date: Tue, 03 Aug 2010 11:53:07 -0400
From: Jason Keltz <jas@cse.yorku.ca>
To: linux-nfs@vger.kernel.org
Subject: exporting to a list of IPs
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi.

Why is it that you cannot NFS export to a list of IPs and have exportfs 
leave the list of IPs in etab without converting over to FQDN?

In Changelog:

2001-09-20 NeilBrown <neilb@cse.unsw.edu.au>
             Anne Milicia <milicia@missioncriticallinux.com>

         * support/export/client.c (client_lookup) call gethostbyadd
         to make sure that we have a canonical hostname, even for
         dotted-quads

Why does mountd need to repeat the gethostbyname() lookup on every host 
even though exportfs already converted over to using hostname?

Thanks,

Jason.
