Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:41236 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262Ab3A3TY1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 14:24:27 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so105536pad.6
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 11:24:27 -0800 (PST)
Message-ID: <5109732C.9080306@gmail.com>
Date: Thu, 31 Jan 2013 00:53:24 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Cannot see contents of files over NFS share.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've shares with the following options in export --

anonuid=1000,anongid=1000,secure,no_subtree_check,ro,fsid=0,crossmnt

(Actually it doesn't matter. If I remove all the options except fsid 
(which's required for nfs4), it still doesn't work.)

I mount the shares with no options and over localhost.

ls works ok, so does cding to various directories and checking it's 
contents, but that's about it.

No program can read the contents of any file; all of them hang, but can 
be stopped by an interrupt signal.

--debug --syslog with rpc.nfsd gives nothing at all, just generic 
startup messages.

On the same machine, I can mount shares from other NFSv4 servers.

Please help!
