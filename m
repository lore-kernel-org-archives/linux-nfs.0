Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab0HXWM3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Aug 2010 18:12:29 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o7OMCSfl025786
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 18:12:28 -0400
Received: from badhat.bos.devel.redhat.com (vpn-235-243.phx2.redhat.com [10.3.235.243])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o7OMCRmR022707
	for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 18:12:27 -0400
Message-ID: <4C7443CB.1090304@RedHat.com>
Date: Tue, 24 Aug 2010 18:12:27 -0400
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
    Tag: pnfs-all-2.6.35-2010-08-19

The Fedora 13 kernel is kernel-2.6.34.5-43.pnfs34.2010.08.19.fc13.<arch>.rpm
The Fedora 14/Devel kernel is kernel-2.6.35.2-9.pnfs35.2010.08.19.fc14.<arch>.rpm
(Note: there are also kernel-debuginfo and kernel-devel rpms for people who 
use things like systemtap probes).

There is no longer support for Fedora 12 kernels.

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
