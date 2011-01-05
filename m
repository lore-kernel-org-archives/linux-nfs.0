Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12006 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab1AEUvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 15:51:52 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH_V8 0/12] NFSv4 find client fix Version 8 
Date: Wed,  5 Jan 2011 15:51:18 -0500
Message-Id: <1294260690-3095-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Version 8 of these patches
Applies to Tronds nfs-for-next branch

New for Version 8:

- moved the reg/unregistration of the back channel transport to the RPC layer.
- Use the small id to pointer translator service to provide a unique callback
identifier.

-->Andy

The back channel server svc_process_common RPC layer pg_authenticate call
[nfs_callback_authenticate] is shared by both the NFSv4.0 and the NFSv4.1
callback threads. It authenticates the incoming request by finding (and
referencing) an nfs_client struct based on the incoming request address
and the NFS version (4). This is akin to the NFS server which authenticates
requests by matching the server address to the exports file client list.

Since there is no minorversion in the search, it may find the wrong
nfs_client struct. For the nfsv4.0 callback service thread, this means it
could find an NFSv4.1 nfs_client. For the NFSv4.1 callback service thread, it
could find an NFSv4.0 instead of v4.1, or find an NFSv4.1 nfs_client with the
wrong session.

The nfs_client is dereferenced at the end of pg_authenticate. Another
nfs_find_client call is done in the NFS layouer per operation dispatcher
routines for NFSv4.0 and in the cb_sequence operation dispatcher routine for
NFSv4.1 after decoding.

This means the callback server could start processing a callback, passing
the pg_authenticate test, and have the nfs_client struct freed between the
pg_authenticate call and the dispatcher operation call. Or, it could have
found the wrong nfs_client in the pg_authenticate call.

The current code has this behavior: If the nfs_client is not found in
pg_authenticate, the request is simply dropped (SVC_DROP). If an nfs_client
is not found in the dispatcher routines NFS4ERR_BADSESSION is returned for
v4.1 requests and NFS4ERR_BADHANDLE for v4.0 requests.

The fix is to implement the v4.0 SETCLIENTID callback_ident and use it to find
the one and only client for v4.0 callbacks, and to associate the sessionid
with the sessions based callback service (v4.1) and use it to identify the
one and only client. This can be done in the NFS layer, in CB_COMPOUND header
processing for v4.0 and in CB_SEQUENCE processing in v4.1.
In both cases, a reference to the found client is held across CB_COMPOUND
processing.

The pg_authenticate method does not have the callback_ident for CB_NULL or
CB_COMPOUND v4.0 processing, so just the server address, nfsversion and
minorversion is used for the client search

For sessions based callback service, the sessionID can't be set until the
return of the CREATE_SESSION call, yet the CB_NULL ping from a server can
be initiated by the server at the receipt of the CREATE_SESSION call before
the response is sent. So for CB_NULL, the sessionid is (usually) not set, and
the sessionid is not used for CB_NULL pg_authenticate client searches.

