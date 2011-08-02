Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46742 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074Ab1HBL6m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2011 07:58:42 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p72BbH14009858
	for <linux-nfs@vger.kernel.org>; Tue, 2 Aug 2011 07:37:17 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p72BwflK115116
	for <linux-nfs@vger.kernel.org>; Tue, 2 Aug 2011 07:58:41 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p72C4HL8021325
	for <linux-nfs@vger.kernel.org>; Tue, 2 Aug 2011 06:04:17 -0600
Message-ID: <4E37E66D.90102@linux.vnet.ibm.com>
Date: Tue, 02 Aug 2011 04:58:37 -0700
From: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        chuck.lever@oracle.com
Subject: State of NFSv4 VolatileFilehandles
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We at IBM receiving multiple customer requests for supporting NFSv4 
server migration.
I have referred to Trond and Chuck's presentations at 2011 Connectathon 
and there appears to be
sizable work remaining. I am not sure if there is any progress made 
since those talks.

I would like to open up a discussion thread on the mailing list to 
understand the latest status.
Also would like to get the input on the Volatile Filehandles (VFH). I 
searched the mailing list, and could not
find any recent discussion on this.

Some discussion points:
- What are the pieces left to attain full client/server support for 
seamless server migration?
- Any discussion/sugestions on the way to implement VFH?  As described 
in RFC 3530 sections 4.2.3 and 4.2.4?
- Are there any community efforts going / about to start in this area? 
so that we can partner and get
   things done instead of duplicating the work.

Thanks a lot for your help
JV
