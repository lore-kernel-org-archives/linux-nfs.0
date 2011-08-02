Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from snt0-omc3-s17.snt0.hotmail.com ([65.55.90.156]:24322 "EHLO
	snt0-omc3-s17.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753615Ab1HBOzB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2011 10:55:01 -0400
Message-ID: <SNT124-W19F265F02349E7025D923AF73B0@phx.gbl>
From: Mrbuddy <buddy_sz@hotmail.com>
To: <linux-nfs@vger.kernel.org>
Subject: A error about mmap
Date: Tue, 2 Aug 2011 14:55:00 +0000
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi  I've goten error hen using mmap,the error come from
for(i=0;i<mapsize;i++)    maddr[i]='A';
when i=12288 it return bus error.
I have a suspicion at extents_holes:
if(i_size <=foff+len)		return -EIO;
here should be changed to if(i_size <foff+len)	return -EIO; 		 	   		  