Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58027 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975Ab2HOHx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2012 03:53:29 -0400
Received: by lbbgj3 with SMTP id gj3so712638lbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Aug 2012 00:53:26 -0700 (PDT)
Message-ID: <502B55A3.3030007@compcenter.org>
Date: Wed, 15 Aug 2012 11:54:11 +0400
From: "Denis V. Nagorny" <dvnagorny@compcenter.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Randomly inaccessible files through NFS
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Using Scientific Linux 6.1 (I think it's equal to RH EL 6.1) we met the 
strange issue.  Several last months we have problem. After one or two 
days of successful work, files on nfs server begins to be randomly 
unacessible.
I doesn't mean that files becames hidden or something like this. It 
means that attempts to open some random files may be unsuccessful. 
Usually restart of nfs server makes situation better but for several 
days only. There are no any messages about errors in logs on server and 
clients machines. Can anybody point me how can I try to understand what 
happens at least. Sorry for my english.

Denis.
