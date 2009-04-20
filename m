From: howard chen <howachen@gmail.com>
Subject: [NFS] Will NFS client use write-back caching?
Date: Mon, 20 Apr 2009 17:56:20 +0800
Message-ID: <b66ddc900904200256yb62b5f7x43ebf70c0ebcdefd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39228 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753518AbZDTJ5a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Apr 2009 05:57:30 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LvqFi-00015u-Ia
	for linux-nfs@vger.kernel.org; Mon, 20 Apr 2009 19:57:26 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

My client is running ext3, which default has 5 seconds of write-back
caching, e.g.

 cat /proc/sys/vm/dirty_writeback_centisecs
499

Now, if this client connect to a NFS (v3), and write data to the NFS,
will write-back caching used?

Or it will fsync() after every write ?

Thanks.

------------------------------------------------------------------------------
Stay on top of everything new and different, both inside and 
around Java (TM) technology - register by April 22, and save
$200 on the JavaOne (SM) conference, June 2-5, 2009, San Francisco.
300 plus technical and hands-on sessions. Register today. 
Use priority code J9JMT32. http://p.sf.net/sfu/p
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

