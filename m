From: Scott Serr <scott-ZQqfhXz8jV/QT0dZR+AlfA@public.gmane.org>
Subject: newer Linux nfs client freeze under load to OpenSolaris server
Date: Thu, 15 Jul 2010 10:44:36 -0600 (MDT)
Message-ID: <20031040.12221279212276848.JavaMail.root@mail>
References: <20664671.12201279211977122.JavaMail.root@mail>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.geeksite.org ([63.227.241.157]:37157 "EHLO
	mail.geeksite.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933733Ab0GOQyu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jul 2010 12:54:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.geeksite.org (Postfix) with ESMTP id 276D036026
	for <linux-nfs@vger.kernel.org>; Thu, 15 Jul 2010 10:44:37 -0600 (MDT)
Received: from mail.geeksite.org ([127.0.0.1])
	by localhost (mail.geeksite.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yZJ31fak0458 for <linux-nfs@vger.kernel.org>;
	Thu, 15 Jul 2010 10:44:36 -0600 (MDT)
Received: from mail.geeksite.org (unknown [192.168.0.202])
	by mail.geeksite.org (Postfix) with ESMTP id DF78B36022
	for <linux-nfs@vger.kernel.org>; Thu, 15 Jul 2010 10:44:36 -0600 (MDT)
In-Reply-To: <20664671.12201279211977122.JavaMail.root@mail>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My Ubuntu 10.04 workstation automounts my OpenSolaris 2008.11 server.  This works and is stable for "light use."  If I hit it hard though with large "cp -a" reads or rsync/unison, then Linux locks up.  The system is non-responsive, the activity light on my switch shows very active until I force the power off on the box.  The activity light to NFS Server is calm during the Linux NFS Client activity.

I believe this happened when I ran Ubuntu 9.04.  It does not happen on 2 other boxes: Ubuntu 8.04 and Gentoo ~2009.  These other boxes are on the same switch 1Gb as the NFS Server, the problemed 10.04 workstation has 2 1Gb switches between.

I've tried nfs mount options vers=3 and udp and tcp, none seem to solve the problem.

I put another 100M switch between my 2 1Gb switches, this seems to work around the problem - no crashing.

Ideas?  Seems harsh that Linux would freeze.
(I'll try with no switches next.)

Thanks for any ideas,
Scott
