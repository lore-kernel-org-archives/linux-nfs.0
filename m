Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879Ab1AUPfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jan 2011 10:35:03 -0500
From: David Howells <dhowells@redhat.com>
To: lsf-pc@lists.linuxfoundation.org
cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [LSF/MM TOPIC] Unified keys for NFS, CIFS and AFS for security data
Date: Fri, 21 Jan 2011 15:34:27 +0000
Message-ID: <3599.1295624067@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


I'd like to propose a discussion topic for the LSF: how best to implement a
common key type for use by NFS, CIFS and AFS such that, say, a kerberos key
can be encapsulated within one and then be pulled out by various filesystems.

Furthermore, it would be necessary to allow the request_key() upcall mechanism
to perform GSSAPI queries.

David
