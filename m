Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:62372 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab1EIO42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 10:56:28 -0400
Received: by pvg12 with SMTP id 12so2382762pvg.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 07:56:28 -0700 (PDT)
Message-ID: <4DC8D37D.20800@gmail.com>
Date: Mon, 09 May 2011 22:56:13 -0700
From: niujin <pippo.oxford@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: nfs's interface and unix fs system call
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi everyone, I'm new to nfs and I read a line of words refering to NFS 
in <Distributed Systems --- Concepts and Design>:
"User programs can access files via Unix system calls without 
recompilication or reloading"

My question is, as far as I know, unix system call include "open" 
operation while NFS server operation does not, it seems to be 
contradictary to the quotings above, why?
