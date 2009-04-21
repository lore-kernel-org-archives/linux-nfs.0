Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:40833 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751126AbZDUCDf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2009 22:03:35 -0400
From: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: Add data cache statistics to nfs-iostat.py
Date: Mon, 20 Apr 2009 19:03:32 -0700
Message-Id: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The first patch adds a --data flag, and prints a line about data being read by NFS

Data Read:     From Server      From Cache           Total   Hit %
               5676.7534MB     1862.0452MB     7538.7987MB  24.70%

The second patch adds a line about write data.  I'm not quire sure about this patch.  I'm seeing oddities where the number of bytes in "NORMALWRITTENBYTES + DIRECTWRITTENBYTES" does not equal SERVERWRITTENBYTES.  In some cases the amount of data written by the app (normalwrittenbytes + directwrittenbytes) is greater than the amount of data written to the server, and in other cases it's less than the amount of data written to the server.  At the moment, i've ascribed that difference to data being written to the local cache and not flushed, but that doesn't make a whole lot of sense.  

Data Written:    To Server        To Cache           Total
                  5.2221MB        0.1951MB        5.4172MB

-kevin


