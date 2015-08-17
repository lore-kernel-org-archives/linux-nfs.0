Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35639 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbHQQxx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:53:53 -0400
Received: by igbjg10 with SMTP id jg10so60314949igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2015 09:53:52 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 17 Aug 2015 09:53:52 -0700
Message-ID: <CAHq5Ms_Xk4zb+a8m063r7PKoAzByGktTqXLJPmyHiEgGRnsBJw@mail.gmail.com>
Subject: NFS AUTH_SYS and container namespaces
From: Earl Ruby <earl@apcera.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've noticed that the way that the NFS protocol is defined for
container namespaces breaks NFS AUTH_SYS authentication.

The way that the NFS AUTH_SYS protocol is defined depends on the
client system's UIDs and GIDs matching the NFS server's UIDs and GIDs
for authenticating file permission rights. So if you have an NFS
server that has files owned by UID 505 and a client with a user with
UID 505 then that user on the client owns those files on the server.

It's up to the server to decide whether or not it wants to trust the
requests coming from a client. Once the server decides that it trusts
the client, any request coming from UID 505 on the client is accepted
as a valid UID 505 request. If that is insufficiently secure for your
environment you shouldn't be using NFS AUTH_SYS. (e.g. Set up NFSv4
and RPCSEC_GSS/Kerberos instead.)

I've been looking at the NFS kernel code noticed that all of the
modules dealing with UID/GID for files use &init_user_ns to determine
the namespace used when determining the UID/GID to send for a user
within a container. A container that has a user with UID 505 / GID 506
which has mounted the same NFS file system no longer owns the files.
The server will reject all access since &init_user_ns translates the
UID/GID and sends UID 100505 / GID 100506 to the server -- the user
inside the container can no longer access their own files via NFS.

The current implementation appears to attempt to increase security by
breaking the NFS protocol. Under the current implementation *no one*
within a container can access files that they could access outside of
a container.

It seems like the NFS modules should be using current_user_ns() to
determine the namespace to use, so that way UID 505 in the container
would appear as UID 505 to the NFS server. I've been working to
implement that fix and test it in my environment. So far I've gotten
reads to work but writes are still translating the container's UID/GID
to the init_user_ns.

-- 
Earl C. Ruby III  @earlruby
Principal Software Engineer
Apcera.com
