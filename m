From: Jeff Garzik <jeff@garzik.org>
Subject: Re: major NFSv4 client regression (-rc7)
Date: Thu, 10 Jan 2008 15:50:53 -0500
Message-ID: <4786852D.8080905@garzik.org>
References: <20080110204119.GA714@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48220 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688AbYAJUvA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 15:51:00 -0500
In-Reply-To: <20080110204119.GA714-oTNwCEtKUwI/11+TDStg7g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Further data point:

Eventually the client degraded into a state when -any- file access on 
NFS-mounted volume "/g" would hang.


