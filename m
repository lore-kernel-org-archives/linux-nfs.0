Return-Path: linux-nfs-owner@vger.kernel.org
Received: from auth-4.ukservers.net ([217.10.138.158]:34701 "EHLO
	auth-4.ukservers.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbaJGPUE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 11:20:04 -0400
From: Carl Hetherington <cth@carlh.net>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com, keyrings@linux-nfs.org
Date: Tue,  7 Oct 2014 16:19:42 +0100
Message-Id: <1412695184-20773-1-git-send-email-cth@carlh.net>
Subject: Patch to keyring and NFS for NFS bug (erroneous uid/gid with NFS4/Kerberos) 
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am re-sending these patches as requested, hopefully with the correct formatting
this time!  

For reference, the bug in question is:
https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1124250
https://bugzilla.redhat.com/show_bug.cgi?id=876705
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=758870

With best regards,
Carl

