From: Sean Dogar <sean@catfeeder.net>
Subject: nhfsstone
Date: Tue, 15 Mar 2005 14:03:40 -0700
Message-ID: <42374DAC.8050408@catfeeder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBJCb-0004bY-V5
	for nfs@lists.sourceforge.net; Tue, 15 Mar 2005 13:03:45 -0800
Received: from [165.139.44.180] (helo=strongbad.catfeeder.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DBJCb-0002no-Hl
	for nfs@lists.sourceforge.net; Tue, 15 Mar 2005 13:03:45 -0800
Received: from localhost (localhost [127.0.0.1])
	by strongbad.catfeeder.net (Postfix) with ESMTP id DF3581B4F4
	for <nfs@lists.sourceforge.net>; Tue, 15 Mar 2005 15:03:44 -0600 (CST)
Received: from strongbad.catfeeder.net ([127.0.0.1])
 by localhost (strongbad [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 23599-10 for <nfs@lists.sourceforge.net>;
 Tue, 15 Mar 2005 15:03:44 -0600 (CST)
Received: from [10.10.1.130] (wsip-68-14-210-162.ph.ph.cox.net [68.14.210.162])
	by strongbad.catfeeder.net (Postfix) with ESMTP id AF24519B13
	for <nfs@lists.sourceforge.net>; Tue, 15 Mar 2005 15:03:42 -0600 (CST)
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

Has anybody used the nfs benchmarking utility "nhfsstone"? 

I can run it, and I can see that it's doing work (it makes test 
directories in the NFS-mounted directory that I start it from), but it 
never finishes it's testing or gives me any performance info.  I've 
tried the various options, including a -t 120 (I thought that this would 
restrict run-time to 120 seconds) and others, but I still get no output, 
even with verbose.  It doesn't send any output to files either.  It just 
runs and runs.   This is on a Redhat 8 machine as a client mounting an 
AIX NFS export. 

The man page is sort of vague, but I get the impression that you can run 
it without any arguments, and it will do a test with the various 
defaults, and eventually should return. 

Does anybody have any idea on this or do you know somewhere to point me 
for more info?  Most of the stuff I've found through Google has been the 
man page itself. 

-Sean


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
