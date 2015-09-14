Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:43708 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbINSab (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 14:30:31 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 14 Sep 2015 12:30:30 -0600
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7EA4338C8065
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 14:30:28 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8EIUSaq59965660
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 18:30:28 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8EIURBt021497
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 14:30:28 -0400
Date: Mon, 14 Sep 2015 13:30:24 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Soumya Koduri <skoduri@redhat.com>, linux-nfs@vger.kernel.org,
        "nfs-ganesha-devel@lists.sourceforge.net"
	<nfs-ganesha-devel@lists.sourceforge.net>,
        Bruce Fields <bfields@redhat.com>, Niels de Vos <ndevos@redhat.com>
Subject: Re: Default ports to be used by NFS side-band protocol services
 (lockd, statd, rquotad)
Message-ID: <20150914183024.GA1277@us.ibm.com>
References: <55F6C773.9050007@redhat.com>
 <55F71073.6090102@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55F71073.6090102@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> Hello,
> 
> On 09/14/2015 09:11 AM, Soumya Koduri wrote:
> > Hi,
> > 
> > In the latest Linux distributions (Fedora), ports 2049 (nfs) and 20048 (mountd) are configured to be opened by default by firewalld service.
> > 
> > Files: '/usr/lib/firewalld/services/nfs.xml' & '/usr/lib/firewalld/services/mountd.xml'.
> Hmm... I didn't know about this... We should probably 
> set the -p 20048 by default via /etc/sysconfig/nfs file or maybe the systemd script?

I believe, mountd already uses /etc/services file by default. So
specifying it in /etc/services would be good. I think RHEL7 has one for
mountd. This is specific to NFSv3 anyway...


Regards, Malahal.

