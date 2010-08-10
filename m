Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from maui.cs.washington.edu ([128.208.5.86]:49772 "EHLO
	maui.cs.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933626Ab0HJXDo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Aug 2010 19:03:44 -0400
Received: from maui.cs.washington.edu (localhost [127.0.0.1])
	by maui.cs.washington.edu (8.14.1/8.14.1/1.10) with ESMTP id o7AMfXEF023088
	for <linux-nfs@vger.kernel.org>; Tue, 10 Aug 2010 15:41:33 -0700
	(envelope-from oystr@maui.cs.washington.edu)
Date: 10 Aug 2010 15:39 PDT
From: Jan Sanislo <oystr@cs.washington.edu>
Subject: Re: page alloc error on nfs4 via automount
To: linux-nfs@vger.kernel.org
Message-Id: <1281479961/oystr@maui.cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We have also noted this behavior locally.  And there is an outstanding
Red Hat bugzilla entry at:

 https://bugzilla.redhat.com/show_bug.cgi?format=multiple&id=593035
