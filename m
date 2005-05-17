From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFSv4 problem ..
Date: Tue, 17 May 2005 16:30:26 -0400
Message-ID: <428A5462.7070903@RedHat.com>
References: <1116158522.12936.28.camel@marvin.hb-consult.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DY8iA-00066d-FL
	for nfs@lists.sourceforge.net; Tue, 17 May 2005 13:30:42 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DY8i8-0001Dm-PV
	for nfs@lists.sourceforge.net; Tue, 17 May 2005 13:30:42 -0700
To: Holger Burde <hburde@t-online.de>
In-Reply-To: <1116158522.12936.28.camel@marvin.hb-consult.de>
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



Holger Burde wrote:
> Hi;
> 
> Doing some experiments with NFSv4 i stumbled over a problem were 'some'
> progs hang on writes others do not. The hangs are 100% reproducable. vi,
> ar hang on every write and nedit works (4 whatever reason ..).
> The progs are only killable with -9. Restarting Services, rebooting etc.
> does not help. The configuration seems ok. I did the test with selinux
> and without (no enforcing) - same result. 
Please do a "echo t > /proc/sysrq-trigger" and post the system traces
of the hung process...

steved.


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
