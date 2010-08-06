Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from puma-mxisp.mxtelecom.com ([83.166.71.4]:53228 "EHLO
	puma.mxtelecom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab0HFMl4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 08:41:56 -0400
Received: from wings.mxtelecom.com ([192.168.2.111])
	by puma.mxtelecom.com with esmtp (Exim 4.66)
	(envelope-from <matthew@mxtelecom.com>)
	id 1OhLvS-0001Ss-OO
	for linux-nfs@vger.kernel.org; Fri, 06 Aug 2010 13:21:26 +0100
Message-ID: <4C5BFE47.8020905@mxtelecom.com>
Date: Fri, 06 Aug 2010 13:21:27 +0100
From: Matthew Hodgson <matthew@mxtelecom.com>
To: linux-nfs@vger.kernel.org
Subject: Tuning NFS client write pagecache
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

Is there any way to tune the linux NFSv3 client to prefer to write data 
straight to an async-mounted server, rather than having large writes to 
a file stack up in the local pagecache before being synced on close()?

I have an application which (stupidly) expects system calls to return 
fairly rapidly, otherwise an application-layer timeout occurs.  If I 
write (say) 100MB of data to an NFS share with the app, the write()s 
return almost immediately as the local pagecache is filled up - but then 
close() blocks for several minutes as the data is synced to the server 
over a slowish link.  Mounting the share as -o sync fixes this, as does 
opening the file O_SYNC or O_DIRECT - but ideally I want to generally 
encourage the client to flush a bit more aggressively to the server 
without the performance hit of making every write explicitly synchronous.

Is there a way to cap the size of pagecache that the NFS client uses?

This is currently on a 2.6.18 kernel (Centos 5.5), although I'm more 
than happy to use something less prehistoric if that's what it takes.

M.

-- 
Matthew Hodgson
Development Program Manager
OpenMarket | www.openmarket.com/europe
matthew.hodgson@openmarket.com
