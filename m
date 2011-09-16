Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:52450 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab1IPKs6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2011 06:48:58 -0400
Received: from smtp06.web.de  ( [172.20.5.172])
	by fmmailgate01.web.de (Postfix) with ESMTP id F11701974CFE3
	for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2011 12:48:45 +0200 (CEST)
Received: from [80.66.224.98] (helo=PC5280)
	by smtp06.web.de with esmtp (WEB.DE 4.110 #2)
	id 1R4VyP-0000kT-00
	for linux-nfs@vger.kernel.org; Fri, 16 Sep 2011 12:48:45 +0200
From: "Tim" <supertimothy@web.de>
To: <linux-nfs@vger.kernel.org>
Subject: Writing / Locking problem with NFSv4
Date: Fri, 16 Sep 2011 12:48:45 +0200
Message-ID: <001101cc745e$356aeed0$a040cc70$@web.de>
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi there

I'm  facing a rather strange problem. 

>From one client I can mount and access my NFSServer without any problems.
Writing and locking works with a non root user accout. 
>From another client (in another subnet), with root everything works fine. If
I use another user, locking doesnt work and also when I create a file with
vim, the *.swp file is not deleted afterwards. But reading works without
problems. 
Strange thing is user mapping seems to work correct - at least what ls -la
and the logfiles for idmapd shows. 

I appreciate your input! Thanks!

Tim

