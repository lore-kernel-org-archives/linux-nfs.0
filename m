From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/6] Implement generic RPC credentials
Date: Thu, 13 Mar 2008 13:59:05 -0400
Message-ID: <1205431145.13453.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24660 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbYCMR75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 13:59:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 protocol allows clients to negotiate security protocols on the
fly in the case where an administrator on the server changes the export
settings and/or in the case where we may have a filesystem migration
event.

Instead of having the NFS client code cache credentials that are tied to
a particular AUTH method it is therefore preferable to have a generic
credential that can be converted into whatever AUTH is in use by the RPC
client when the read/write/sillyrename/... is put on the wire.
    
We do this by means of a new "generic" credential, which basically just
caches the minimal information that is needed to look up an RPCSEC_GSS,
AUTH_SYS, or AUTH_NULL credential.

We then ensure that when the rpc_init_task attempts to bind this
credential is bound to the task, it results in a lookup of a cred for
whatever auth mechanism is currently the default in task->tk_client.

-- 
Trond Myklebust
NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
