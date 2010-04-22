Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp151.dfw.emailsrvr.com ([67.192.241.151]:49870 "EHLO
	smtp151.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0DVSPB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 14:15:01 -0400
Received: from relay15.relay.dfw.mlsrvr.com (localhost [127.0.0.1])
	by relay15.relay.dfw.mlsrvr.com (SMTP Server) with ESMTP id 517C530B02A1
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 14:14:59 -0400 (EDT)
Received: by relay15.relay.dfw.mlsrvr.com (Authenticated sender: brandon-AT-myshape.com) with ESMTPA id 208B930B10AC
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 14:14:59 -0400 (EDT)
From: "Brandon Shandelson" <brandon@myshape.com>
To: <linux-nfs@vger.kernel.org>
References: 
In-Reply-To: 
Subject: RE: NFSV4 Replica Support?
Date: Thu, 22 Apr 2010 11:16:20 -0700
Message-ID: <01c701cae247$e8e50900$baaf1b00$@com>
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I want to use NFSV4 replicas on Ubuntu 9.10 64-bit servers.  It doesn't seem
to work.  It *looks* like the server kernel module supports it, but the NFS
client does not.  Is this the case, or should I be able to make replicas
work on Linux?

