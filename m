Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:63122 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab1DQJX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Apr 2011 05:23:29 -0400
Received: by ewy4 with SMTP id 4so1111514ewy.19
        for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2011 02:23:28 -0700 (PDT)
Date: Sun, 17 Apr 2011 18:23:26 +0900
Message-ID: <BANLkTi=3mcfWuFhoCzetzuguA2vA02AShg@mail.gmail.com>
Subject: NFSv3 client caches dozens or hundreds of megabytes before sending a
 write request to NFS server.
From: crocket <crockabiscuit@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Let me explain my network configuration.

Internet <--------------------> eth0 | the linux router | eth1
<------------------------------> eth0 | the desktop.

The linux router is actually a proper computer but not a router that
has linux firmware.
eth1 on the router and eth0 on the desktop are both full-duplex at 100Mbps.
The full-duplex connection is confirmed using netcat like
http://imagebin.org/148650
And they also remain full-duplex during NFS transfers according to "ethtool".

The router runs an NFS server, and the desktop uses an NFS client.

On the desktop, if I download files from the internet to the NFS
server, the client caches dozens or hundreds of megabytes before
sending data to the server like http://imagebin.org/148648
As a result, the download pauses frequently to send data to the NFS
server until the download is finished.
I want NFS client to forward downloaded data to the server immediately
instead of after caching.
In other words, I want NFS transfer to be http://imagebin.org/148650
but not http://imagebin.org/148648

Does anybody know how to solve this issue?
