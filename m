From: Chuck Lever <chuck.lever@oracle.com>
Subject: 2008 mountd clean-up patch
Date: Thu, 27 Aug 2009 15:34:24 -0400
Message-ID: <1F6E13E6-2D6F-4B80-B4E6-1B251012AF5A@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Frank S Filz <ffilz@us.ibm.com>, Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:51124 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbZH0Tel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2009 15:34:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm looking at a 2008 nfs-utils clean up done in commit 7a817c45.  It  
has this hunk in it:

@@ -111,7 +111,7 @@ void auth_unix_ip(FILE *f)
         else if (client)
                 qword_print(f, *client?client:"DEFAULT");
         qword_eol(f);
-       xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, *client? 
client: "DEFAULT");
+       xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client? 
client: "DEFAULT");

         if (client) free(client);
         free(he);

You changed the '*client ? client : "DEFAULT"' expression in the  
xlog() call, but not in the qword_print() call right above it.  Which  
of these is correct, and why do they need to be different from each  
other?

Seems to me _both_ should be 'client ? client : "DEFAULT"' (ie.  
without the dereference).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



