From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: [RFC] nfsstat v4 layout
Date: Wed, 16 Mar 2005 12:37:59 -0500
Message-ID: <20050316173759.GA4360@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBcTD-0003XP-Vy
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 09:38:11 -0800
Received: from mta10.adelphia.net ([68.168.78.202])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DBcTC-0004Hy-Gi
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 09:38:11 -0800
Received: from harpo.ny.gam3.net ([68.235.28.141]) by mta10.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050316173804.JAHU7277.mta10.adelphia.net@harpo.ny.gam3.net>
          for <nfs@lists.sourceforge.net>; Wed, 16 Mar 2005 12:38:04 -0500
Received: from gam3 by harpo.ny.gam3.net with local (Exim 3.36 #1 (Debian))
	id 1DBcT1-00018i-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Mar 2005 12:37:59 -0500
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


I made a patch to nfsstat to display v4 stats.
I am having a problem with some of the names being so
long setclientid_confirm for instance.  

Is the format below too confusing?  Anyone have a better idea?

Client nfs v4:
null        read        write       commit      open        *_confirm   
0       0%  0       0%  0       0%  0       0%  0       0%  0       0%  
*_noattr    *_downgrade close       setattr     fsinfo      renew       
0       0%  0       0%  0       0%  0       0%  0       0%  0       0%  
setclientid *_confirm   lock        lockt       locku       access      
0       0%  0       0%  0       0%  0       0%  0       0%  0       0%  
getattr     lookup      lookup_root remove      rename      link        
0       0%  0       0%  0       0%  0       0%  0       0%  0       0%  
symlink     create      pathconf    statfs      readlink    readdir     
0       0%  0       0%  0       0%  0       0%  0       0%  0       0%  
server_caps delegreturn 
0       0%  0       0%  


Allen Morris <gam3@gam3.net>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
