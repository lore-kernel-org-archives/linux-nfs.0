Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbbINNLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2015 09:11:19 -0400
From: Soumya Koduri <skoduri@redhat.com>
Subject: Default ports to be used by NFS side-band protocol services (lockd,
 statd, rquotad)
To: linux-nfs@vger.kernel.org,
        "nfs-ganesha-devel@lists.sourceforge.net"
	<nfs-ganesha-devel@lists.sourceforge.net>,
        Bruce Fields <bfields@redhat.com>, Steve Dickson <steved@redhat.com>
Cc: Niels de Vos <ndevos@redhat.com>
Message-ID: <55F6C773.9050007@redhat.com>
Date: Mon, 14 Sep 2015 18:41:15 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

In the latest Linux distributions (Fedora), ports 2049 (nfs) and 20048 
(mountd) are configured to be opened by default by firewalld service.

Files: '/usr/lib/firewalld/services/nfs.xml' & 
'/usr/lib/firewalld/services/mountd.xml'.

We would like to know what ports could be used by default for service 
daemons providing other NFS side-band protocols (NLM/NSM/RQUOTA), so 
that we can define *.xml files for those services as well to be included 
in firewalld if required.

Request your inputs.

Thanks,
Soumya



