Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35024 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbaASS15 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jan 2014 13:27:57 -0500
Received: by mail-pd0-f171.google.com with SMTP id g10so5240262pdj.2
        for <linux-nfs@vger.kernel.org>; Sun, 19 Jan 2014 10:27:56 -0800 (PST)
Received: from mail.fuckthenavy.net ([94.100.23.163])
        by mx.google.com with ESMTPSA id g6sm54528880pat.2.2014.01.19.10.27.55
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jan 2014 10:27:55 -0800 (PST)
Received: from localhost.localdomain (108-226-169-95.lightspeed.austtx.sbcglobal.net [108.226.169.95])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.fuckthenavy.net (Postfix) with ESMTPSA id 71CD3249E5
	for <linux-nfs@vger.kernel.org>; Sun, 19 Jan 2014 18:27:52 +0000 (UTC)
Message-ID: <52DC1926.10600@fuckthenavy.net>
Date: Sun, 19 Jan 2014 18:27:50 +0000
From: Justus Ranvier <justusranvier@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv4 guest opens random ports
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have systems running Gentoo Linux mounting shares hosted on a Gentoo
Linux server. All are running 3.12.8 kernels and using NFS 4.

I've followed all instructions I can find for fixing everything to a
static port, but I still see one instance ofrandom port behavior.

A kernel process (does not display a PID in netstat) on the guests is
opening listening sockets on random high-numbered ports. The server is
attempting to contact those guests via random low-numbered ports, which
my firewall is blocking.

Despite these packets being blocked, I haven't noticed any adverse
effects - everything appears to work normally except for my system logs
on the server being spammed with blocked outgoing connection attempts.

What is this random port the client is trying to accept connections on,
and how do I make it listen on a fixed port instead of a random one so
that I can write useful firewall rules?
