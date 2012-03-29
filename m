Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:49131 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846Ab2C2Q26 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 12:28:58 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SDIDW-0007NP-G6
	for linux-nfs@vger.kernel.org; Thu, 29 Mar 2012 18:28:55 +0200
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 29 Mar 2012 18:28:53 +0200
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 29 Mar 2012 18:28:53 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: [nfsv4] =?utf-8?b?b3BlbihPX0NSRUFUKQ==?= returns EEXISTS on symbolic link created on another system until stat()ed
Date: Thu, 29 Mar 2012 16:28:42 +0000 (UTC)
Message-ID: <loom.20120329T182500-467@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I filed a bug here: https://bugzilla.redhat.com/show_bug.cgi?id=808112

Description of problem:

client A:
touch blah
ln -s blah blahlink

client B:
open("blahlink", O_RDONLY|O_CREAT, 0666) = -1 EEXIST (File exists)
$ ls -l blahlink
lrwxrwxrwx. 1 orion cora 4 Mar 29 09:30 blahlink -> blah
open("blahlink", O_RDONLY|O_CREAT, 0666) = 3

Removing and recreating the link on client A restores the problem.

earth:/export/home/orion on /home/orion type nfs
(rw,noatime,intr,rsize=32768,wsize=32768,actimeo=1,sloppy,vers=4)

I thought this might be the same as the recent stat() issue brought up in
relation to viminfo files, but it fails on kernels with that fix.

I can't reproduce on RHEL5 kernel 2.6.18-308.1.1.el5, but I can on
2.6.42.9-2.fc15.x86_64 through 3.4.0-0.rc0.git1.2.fc18.x86_64.

