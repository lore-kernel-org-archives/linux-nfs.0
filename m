From: Chip Salzenberg <chip@pobox.com>
Subject: Updating config.guess and config.sub
Date: Wed, 6 Apr 2005 15:01:29 -0400
Message-ID: <20050406190129.GO12946@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJFmS-0007ug-MB
	for nfs@lists.sourceforge.net; Wed, 06 Apr 2005 12:01:36 -0700
Received: from perlsupport.com
	([66.180.163.120] helo=mail.perlsupport.com ident=f83603f41df9d96594ad009abb999685)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DJFmR-0002xl-9l
	for nfs@lists.sourceforge.net; Wed, 06 Apr 2005 12:01:36 -0700
Received: from [67.132.206.254] (helo=tytlal)
	by mail.perlsupport.com (Exim 4) with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	id 1DJFmP-0001Hj-2u
	for nfs@lists.sourceforge.net; Wed, 06 Apr 2005 15:01:33 -0400
Received: from chip by tytlal with local (Exim 4.50)
	id 1DJFmL-00084U-Aq
	for nfs@lists.sourceforge.net; Wed, 06 Apr 2005 15:01:29 -0400
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

I'm planning to close a Debian bug by updating config.guess and
config.sub in the nfs-utils CVS.  We haven't made any local hacks to
those files, have we?  If not I'll just overwrite them with current
versions.
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
