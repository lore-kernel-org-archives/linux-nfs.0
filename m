Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:36106 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbcGGKtn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 06:49:43 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id C1F57280B06
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jul 2016 12:49:40 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id B520D13E92
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jul 2016 12:49:39 +0200 (MEST)
Date: Thu, 7 Jul 2016 12:49:39 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Andy Adamson <william.adamson@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <steved@redhat.com>
Message-ID: <1485779983.22627050.1467888579184.JavaMail.zimbra@desy.de>
Subject: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Dear NFS folks,

we observe orphan open-states on our deployment with nfsv4.1.
Our setup - two client nodes, running RHEL-7.2 with kernel
3.10.0-327.22.2.el7.x86_64. Both nodes running ownCloud (like
a dropbox) which nfsv4.1 mounts to dCache storage. Some clients
connected to node1, others to node2.

Time-to-time we see some 'active' transfers on data our DS
which do nothing. There is a corresponding state on MDS.

I have traced one one such cases:

  - node1 uploads the file.
  - node2 reads the file couple of times, OPEN+LAYOUTGET+CLOSE
  - node2 sends OPEN+LAYOUTGET
  - there is no open file on node2 which points to it.
  - CLOSE never send to the server. 
  - node1 eventually removes the removes the file

We have many other cases where file is not removed, but this one I was
able to trace. The link to capture files:

https://desycloud.desy.de/index.php/s/YldowcRzTGJeLbN

We had ~ 10^6 transfers in last 2 days and 29 files in such state (~0.0029%).

Tigran.
