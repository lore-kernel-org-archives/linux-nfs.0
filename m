Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:40060 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab0JMVUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 17:20:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id C2005B1BAE
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 23:11:52 +0200 (CEST)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ukjdeckwArFc for <linux-nfs@vger.kernel.org>;
	Wed, 13 Oct 2010 23:11:50 +0200 (CEST)
Received: from [90.184.13.151] (2605ds1-ynoe.2.fullrate.dk [90.184.13.151])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: jesper@krogh.cc)
	by shrek.krogh.cc (Postfix) with ESMTPSA id D1335B1B35
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 23:11:49 +0200 (CEST)
Message-ID: <4CB62095.4010708@krogh.cc>
Date: Wed, 13 Oct 2010 23:11:49 +0200
From: Jesper Krogh <jesper@krogh.cc>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: lsof and open files from the nfs-server
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi.

Quite often when you have to umount a fileshare you get the
message "Device or resource busy". Typically I traverse through
the output of lsof | grep mountpoint and stop processes or kill
until I can safely umount.

But the nfs-kernel-server does not register its open files, so
seen from userspace is it extremely hard to find out that is actually
is the nfs-server that prevents you from being able to umount
the filesystems.

Would it be possible to register the open files the same place
so administrators can see them?

... basically just a feature-request from one who just spend an hour on 
that.

-- 
Jesper
