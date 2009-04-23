From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Client NFS pachtes workflow
Date: Thu, 23 Apr 2009 14:38:03 +0200
Message-ID: <20090423123803.GH57877@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:49900 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755768AbZDWMiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 08:38:05 -0400
Received: from kazi.fit.vutbr.cz (localhost [127.0.0.1])
	by kazi.fit.vutbr.cz (envelope-from kasparek@fit.vutbr.cz) (8.14.3/8.14.3) with ESMTP id n3NCc3ZY054976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2009 14:38:03 +0200 (CEST)
Received: (from kasparek@localhost)
	by kazi.fit.vutbr.cz (8.14.3/8.13.1/Submit) id n3NCc3R8054975
	for linux-nfs@vger.kernel.org; Thu, 23 Apr 2009 14:38:03 +0200 (CEST)
	(envelope-from kasparek@fit.vutbr.cz)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

while searching some more info for my problems with 2.6.27.x & client
packet flow & lockd, I tried to find the flow of patches for NFS clients.
For older one, there are dierctories in
http://www.linux-nfs.org/Linux-2.6.x/ (up to 28-rc9). Does it mean patches
in 2.7.27 originated in time after 2.6.27 was out and were included in
28-rc5 (next dir). Some of the patches seem to correct bugs, do they get
into 27.x by default or is it necessary to ask somewhere (GregKH)? 

I found http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git, but that seems to
be just tracking branches, is it possible to use that tree to track NFS
client changes easily? (I'm not git power user so maybe it's just about
knowing the right command).

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

