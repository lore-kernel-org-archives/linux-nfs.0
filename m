Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14097 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167Ab1DKUwG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 16:52:06 -0400
Received: from [10.30.16.32] (jcohen5-lxp.hq.netapp.com [10.30.16.32] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p3BKq3Ew016853
	for <linux-nfs@vger.kernel.org>; Mon, 11 Apr 2011 13:52:04 -0700 (PDT)
Message-ID: <4DA369F3.4020603@netapp.com>
Date: Mon, 11 Apr 2011 16:52:03 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Jenkins NFS CI
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi everybody!

I have posted my initial jenkins CI setup to a git repo located at: git://git.linux-nfs.org/projects/bjschuma/jenkins-nfs.git.  I would appreciate feedback for making it both more useful and usable.  I have it configured to test client changes, I haven't given much thought for testing the server.

You can find instructions for setting it up here: https://wiki.linux-nfs.org/wiki/index.php/Jenkins_CI and also in the README.txt I placed in the root of the git tree.

I have also created pre-configured virtual machine images that can be used with libvirt for running the tests.  You can download them from http://linux-nfs.org/~bjschuma/jenkins_master.32.img and http://linux-nfs.org/~bjschuma/jenkins_master.64.img.

Thanks for any feedback!
- Bryan
