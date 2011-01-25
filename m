Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29560 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117Ab1AYXag convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 18:30:36 -0500
Subject: 2.6.38-rc2... NFS sillyrename is broken...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Jan 2011 18:30:15 -0500
Message-ID: <1295998215.6867.22.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Something in the recent VFS churn appears to have broken NFS
sillyrename.

Currently, when I try to unlink() a file that is being held open by
another process, I do indeed see that file getting renamed to
a .nfsxxxxxxx file, but when the file is closed, the .nfsxxxxx file
sticks around until I unlink() it again.

I'll have a look tomorrow at what is going wrong, but I figured I'd ask
on the list in case someone has a suspect...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

