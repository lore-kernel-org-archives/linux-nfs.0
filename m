From: Ray <whatdoineed2do@yahoo.co.uk>
Subject: Re: nfs-utils-1.0.10/linux 2.6.18 bug? unable to start nfsd;
	nfssvc "Address already in use"
Date: Sat, 18 Nov 2006 10:42:29 +0000 (GMT)
Message-ID: <20061118104230.24911.qmail@web23307.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GlNex-0003tk-6q
	for nfs@lists.sourceforge.net; Sat, 18 Nov 2006 02:42:56 -0800
Received: from web23307.mail.ird.yahoo.com ([217.146.189.77])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GlNeu-0000Su-OZ
	for nfs@lists.sourceforge.net; Sat, 18 Nov 2006 02:42:55 -0800
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

>> issue is, using 2.6.18.2 kernel and 1.0.10 nfs
utils
>> but i am periodically having problems starting nfsd
--
>> it drops out after sysloging that "nfssvc "Address
>> already in use" when there are actually no other
nfsd
>> instances running
 
> Have you checked to see if port 2049 is in use?

hi,
had the same problem again, and running 'netstat
-anptu | grep :2049' as root tells me that the statd
had stolen that port 

udp        0      0 0.0.0.0:2049            0.0.0.0:* 
                         954/rpc.statd

i think this is to do with the manner in which FC2
starts the nfs (and related services) -- the 'nfs'
service starts nfsd/quotad/mountd whilst there is a
seperate 'nfslock' service which starts lockd and it
is this latter service which is started first.

i'll take a look at the scripts and re-order them.
many thanks for the pointers
ray

Send instant messages to your online friends http://uk.messenger.yahoo.com 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
