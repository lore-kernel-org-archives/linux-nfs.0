From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: busy mounts (due to io ?)
Date: Thu, 7 Apr 2005 02:10:58 -0700 (PDT)
Message-ID: <20050407091058.53015.qmail@web51610.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJT2W-0002sZ-PH
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 02:11:04 -0700
Received: from web51610.mail.yahoo.com ([206.190.38.215])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DJT2W-0004lz-6x
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 02:11:04 -0700
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
       I have RHEL4 GA installed on my machine.
       filesystems do net get umounted even
       after unexporting all exported filesystems.
       This happens only if client was doing io to
       server.

       #cat /proc/net/rpc/nfsd

        rc 6 5158 3068
        fh 174 0 0 0 0
        io 3423168 148232768
        th 16 4 6.168 2.532 5.040 1.934 3.607 0.171   
          0.028 0.071 0.005 0.006
        ra 32 0 0 0 0 0 0 0 0 0 0 283
        net 8236 8194 30 30
        rpc 8232 0 0 0 0
        proc2 18 31 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
        proc3 22 30 1082 0 741 413 0 283 4567 288 240
          0 0 42 26 1 0 0 181 10 2 0 295
        proc4 2 0 0

        After huge number of retries (30-40) , umount
        succeeds.
        From above output , nfs server does not
        seemsto be much busy.
        Umount is successful immediately after
        killing nfsd
        Using iostat command , i ca nsee that io is
        going on disk and hence is busy but why does
        it take  such a long time to complete the io,
        though nfs servers are not busy.
        Systems on which nfs is running are not at
        all heavily loaded.
        This problem is only on RedHat(GA,update1)
        and not on  suSE 9

thanks,
 --kiran


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Personals - Better first dates. More second dates. 
http://personals.yahoo.com



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
