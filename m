Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bn1bon0132.outbound.protection.outlook.com ([157.56.111.132]:38432
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753904AbaIYPtN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2014 11:49:13 -0400
Message-ID: <5424156C.8080602@eas.gatech.edu>
Date: Thu, 25 Sep 2014 09:15:24 -0400
From: MJ Jenkins <mack.jenkins@eas.gatech.edu>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: NFS Share To OS X
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a user who is on a Mac, and has some data on our RedHat 
Enterprise Linux(RHEL) server that needs to be shared to another RHEL 
box and to her Mac.  All seems to be fine on the RHEL box, and somewhat 
on the Mac.

The problem comes in when the user on the Mac writes files to the NFS 
share.  On the RHEL side the files are owned by user root and group 
nfsnobody.  Has anyone else run into this issue?  I'm not sure if the 
issue is how I am exporting the share to the Mac, or how I have the 
share mounted on the Mac.

Any assistance is greatly appreciated.

Mack

