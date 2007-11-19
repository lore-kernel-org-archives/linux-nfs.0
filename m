From: "Shiney James" <shineyjames@gmail.com>
Subject: [NFS] rpc.statd
Date: Mon, 19 Nov 2007 15:06:44 -0800
Message-ID: <1b378070711191506o14ce99feo37c2a75bfdc4e47e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuFhQ-0002kl-Q6
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 15:06:47 -0800
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuFhV-00016w-HC
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 15:06:46 -0800
Received: by nf-out-0910.google.com with SMTP id 4so5400011nfv
	for <nfs@lists.sourceforge.net>; Mon, 19 Nov 2007 15:06:44 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

I would greatly appreciate if someone could help me regarding the following..

>From the manuals it is understood that rpc.statd can configured to
listen on a particular port for  incoming request and a port for
outgoing request. This can be done by setting STATD_PORT and
STATD_OUTGOING_PORT. But even after setting these I find that there is
a port opened other than the above.

netstat -anop | grep rpc.statd output is pasted below.

[root@fs01 root]# netstat -anop | grep rpc.statd
tcp        0      0 0.0.0.0:48000         0.0.0.0:*
LISTEN      4334/rpc.statd      off (0.00/0/0)
udp        0      0 0.0.0.0:48000           0.0.0.0:*
         4334/rpc.statd      off (0.00/0/0)
udp        0      0 0.0.0.0:694             0.0.0.0:*
         4334/rpc.statd      off (0.00/0/0)
unix  2      [ ]         DGRAM                    5378   4334/rpc.statd

I have set STATD_PORT as 48000 as is seen. But I am not sure why port
694 is also being used?
Any idea?

Thanks
Shiney

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

