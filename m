Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:59180 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab1AaJoo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jan 2011 04:44:44 -0500
From: =?utf-8?q?=C5=81ukasz_Ole=C5=9B?= <lukasz.oles@open-e.com>
To: linux-nfs@vger.kernel.org
Subject: Testing sm-notify
Date: Mon, 31 Jan 2011 10:45:01 +0100
Cc: Artur Piechocki <artur.piechocki@open-e.com>
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201101311045.02517.lukasz.oles@open-e.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I am using nfs-utils version 1.2.3. I am trying to test sm-notify, I have 2 
test scenarios:

First one:
1 server, 2 clients - client 1 locks file on nfs server, client 2 is trying to 
lock the same file and waiting.  I'm restarting client 1, client 2 locks file.
Everything works fine

Second:
1 server, 1 client - client locks file. I'm restarting server and  client 
should relock file, but I don't know any program which can do it. 

How do you testing this scenario? Can you recommend any program which can 
automaticly lock file again?


Regards,

--
Łukasz Oleś
