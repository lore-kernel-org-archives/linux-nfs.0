From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: NFSv4 support on SuSE 9 sp1
Date: Thu, 10 Mar 2005 05:55:58 -0800 (PST)
Message-ID: <20050310135558.51770.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9O90-0003jG-1P
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 05:56:06 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1D9O8y-00020M-88
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 05:56:05 -0800
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

Hi , 
  Is nfsv4 supported on SuSE 9 sp1 rc5.
  SuSE 9 sp1 rc5 is not able to mount
  nfs4 filesystems.

  when i tried mount -t nfs4  server:/ /share
  it gives error :
  nfs_read_super : missing data argument.
  

  I the recomplied kernel with additional 
  CONFIG_NFSD_V4=y (not enabled with default config 
  that comes with SuSE) and tried but i faced the same

  error.

  RHEL4 GA machine was acting as NFS server.
  Other RHEL4 machine could mount the nfs4 filesystem.

thanks,
 --kiran
  

   

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
