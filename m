From: Chip Salzenberg <chip@pobox.com>
Subject: Any reason why 1.2.3.4/255.255.255.255 wouldn't be valid in exports?
Date: Thu, 10 Mar 2005 12:55:56 -0500
Message-ID: <20050310175556.GB4577@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9RtH-0007bj-HC
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 09:56:07 -0800
Received: from perlsupport.com
	([66.180.163.120] helo=mail.perlsupport.com ident=64e6eb56b3f089ca9d73fa8daedaa274)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D9RtD-0006f7-UF
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 09:56:07 -0800
Received: from [67.132.206.254] (helo=tytlal)
	by mail.perlsupport.com (Exim 4) with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	id 1D9Rt6-0002Sk-WB
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 12:55:57 -0500
Received: from chip by tytlal with local (Exim 4.50)
	id 1D9Rt6-0001Jy-3X
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 12:55:56 -0500
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

A Debian user is reporting that this exports line:

  /backup 192.168.0.8/255.255.255.255(no_root_squash,rw,async)

is causing trouble:

  "From the client an 'rpcinfo -u nfsserver nfs' ended in a TIMEOUT."

Meanwhile this:

  /backup 192.168.0.8(no_root_squash,rw,async)

works fine for him.

Bug?  Feature?  Something needing to be documented?
-- 
Chip Salzenberg            - a.k.a. -            <chip@pobox.com>
         Open Source is not an excuse to write fun code
            then leave the actual work to others.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
