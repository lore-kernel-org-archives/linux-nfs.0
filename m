Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755122Ab0JALE7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 07:04:59 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o91B4w4A007091
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 07:04:58 -0400
Received: from badhat.bos.devel.redhat.com (vpn-225-4.phx2.redhat.com [10.3.225.4])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o91B4vxr002915
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 07:04:58 -0400
Message-ID: <4CA5C059.6000805@RedHat.com>
Date: Fri, 01 Oct 2010 07:04:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Updated pNFS Developmental kernel repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've updated the Fedora pNFS development repository to include the
Fedora 13, 14 and Devel kernels that have the latest pNFS bits:

    Tag: pnfs-all-2.6.35-2010-09-14     for Fedora 13 and 14 kernels
    Tag: pnfs-all-latest                for Devel/f15 kernels

(Note: there are also kernel-debuginfo and kernel-devel rpms for people who 
use things like systemtap probes and crash).

I have not updated the nfs-utils rpms because I'm waiting 
for a fix to a problem in rpc.mountd. Once the problem is resolve
I'll update those rpms as well... 

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
