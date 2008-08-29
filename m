From: Doug Hughes <doug-rDJHdQPhaF8@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11448] New: NFS client has inconsistent write
 flushing to non-linux serversa
Date: Fri, 29 Aug 2008 08:54:43 -0400
Message-ID: <48B7F193.6040606@will.to>
References: <bug-11448-10286@http.bugzilla.kernel.org/> <20080828132753.08bfe05f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman.will.to ([68.164.136.125]:37616 "EHLO will.to"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbYH2Myx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 08:54:53 -0400
In-Reply-To: <20080828132753.08bfe05f.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

confirmed that this bug is present in same way in 2.6.26 using default 
ASYNC NFS, but so far does not exhibit when sync mount option is used.

