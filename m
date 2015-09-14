Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbbINSWo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2015 14:22:44 -0400
Subject: Re: Default ports to be used by NFS side-band protocol services
 (lockd, statd, rquotad)
To: Soumya Koduri <skoduri@redhat.com>, linux-nfs@vger.kernel.org,
        "nfs-ganesha-devel@lists.sourceforge.net"
	<nfs-ganesha-devel@lists.sourceforge.net>,
        Bruce Fields <bfields@redhat.com>
References: <55F6C773.9050007@redhat.com>
Cc: Niels de Vos <ndevos@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55F71073.6090102@RedHat.com>
Date: Mon, 14 Sep 2015 14:22:43 -0400
MIME-Version: 1.0
In-Reply-To: <55F6C773.9050007@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 09/14/2015 09:11 AM, Soumya Koduri wrote:
> Hi,
> 
> In the latest Linux distributions (Fedora), ports 2049 (nfs) and 20048 (mountd) are configured to be opened by default by firewalld service.
> 
> Files: '/usr/lib/firewalld/services/nfs.xml' & '/usr/lib/firewalld/services/mountd.xml'.
Hmm... I didn't know about this... We should probably 
set the -p 20048 by default via /etc/sysconfig/nfs file or maybe the systemd script?

> 
> We would like to know what ports could be used by default for service 
> daemons providing other NFS side-band protocols (NLM/NSM/RQUOTA), so 
> that we can define *.xml files for those services as well to be included in 
> firewalld if required.
The actual port number really does not matter, as long as its
not a  privileged port (< 1024). What matters is the port you assign 
to the servers are actually used... Which means the default configuration 
files (like /etc/sysconfig/nfs) are updated with the given port numbers.

steved.
