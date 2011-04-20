Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mao.cendio.se ([193.12.253.101]:41570 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753450Ab1DTH07 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 03:26:59 -0400
Received: from stella (dmz-gw.cendio.se [193.12.253.97])
	by mail.cendio.se (Postfix) with ESMTP id 5246D13817B
	for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 08:58:31 +0200 (CEST)
Date: Wed, 20 Apr 2011 08:58:31 +0200 (CEST)
From: =?ISO-8859-15?Q?Peter_=C5strand?= <astrand@cendio.se>
To: linux-nfs@vger.kernel.org
Subject: Save the unfs3 project
Message-ID: <alpine.LFD.2.02.1104191614010.23639@stella.lkpg.cendio.se>
Content-Type: MULTIPART/MIXED; BOUNDARY="789238273-640111187-1303222841=:23639"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--789238273-640111187-1303222841=:23639
Content-Type: TEXT/PLAIN; FORMAT=flowed; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LFD.2.02.1104191623371.23639@stella.lkpg.cendio.se>


Hi! I am one of the developers of the "unfs3" server. Unfortunately, the 
maintainer Pascal Schmidt has disappeared from the net. I've been hosting 
the source repository, but I do not have admin access to the Sourceforge 
unfs3 project. This means that I cannot make new releases or maintain the 
project. Now, the problem is that Sourceforge no longer accepts Abandoned 
Project Takeovers.

I can of course host the project somewhere else, but Google Code does not 
accept project names which exists on SF, nor do they offer Subversion 
imports, and I believe it would be quite confusing for old users to have a 
"dead" project at SF. Switching to another name doesn't seem very 
practical neither.

So, if anyone of you knows where Pascal Schmidt can be reached, or have 
some idea of how the SF staff can be convinced to do a Abandoned Project 
Takeover, please let me know. There's a ticket at 
https://sourceforge.net/apps/trac/sourceforge/ticket/17261 .

Another option, I guess, would be to discontinue the unfs3 project and 
recommend users to migrate to nfs-ganesha, or something like that. Any 
users of ganesha on this list? I don't know much about it. Unfortunately 
it seems like it does not support Windows, which we need.

Best regards, 
---
Peter Åstrand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.com
Wallenbergs gata 4
583 30 Linköping	Phone: +46-13-21 46 00
--789238273-640111187-1303222841=:23639--
