Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.uvm.edu ([132.198.101.169]:54189 "EHLO smtp2.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbZBQVYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2009 16:24:44 -0500
Received: from planck.local ([132.198.107.214])
	(authenticated bits=0)
	by smtp2.uvm.edu (8.14.2/8.14.2) with ESMTP id n1HKhRKr006160
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 15:43:27 -0500
Message-ID: <499B217A.2010504@uvm.edu>
Date: Tue, 17 Feb 2009 15:43:38 -0500
From: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
To: linux-nfs@vger.kernel.org
Subject: getattr miss
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Forgive me for what may be an obvious question.  In the middle of 
tracking down NFS4ERR_RESOURCE storms from an AIX server to linux 
clients on three busy webservers, I noticed that our linux client 
performs a compound OPEN,GETATTR for every read of a file even if the 
reads are well within the attribute cache timeout.  Adding nocto doesn't 
seem to change this behavior -- and for apache looking up numerous 
.htaccess files it would be great to avoid the trip to the server to 
revalidate attributes if we're within the timeout.

So the simple question: is this expected?  I'd like to minimize 
consecutive GETATTR calls, if possible, and get the most from VFS cache.

I've got some ridiculous timeouts set up at this point:

barasinga.uvm.edu:/ on /fs/barasinga type nfs4 
rw,sec=krb5,nocto,hard,intr,actimeo=3600,addr=132.198.101.73

Ben
-- 
Benjamin Coddington
Systems Architecture and Administration
Enterprise Technology Services
University of Vermont
