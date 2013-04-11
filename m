Return-Path: linux-nfs-owner@vger.kernel.org
Received: from maui.cs.washington.edu ([128.208.5.86]:39540 "EHLO
	maui.cs.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab3DKTir (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2013 15:38:47 -0400
Date: 11 Apr 2013 12:22 PDT
From: Jan Sanislo <oystr@cs.washington.edu>
Subject: nfsidmap timeout patch
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com, steved@redhat.com
Message-Id: <1365708135/oystr@maui.cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just wondering if the nfsidmap patch given in

	https://patchwork.kernel.org/patch/1627521/

is going to make it into F19.  It doesn't seem to be there
at present.  It might be useful in helping to mitigate/resolve

	https://bugzilla.redhat.com/show_bug.cgi?id=876705
