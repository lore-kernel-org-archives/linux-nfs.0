From: Michael <mogmios@mlug.missouri.edu>
Subject: Re: auto-discovery of exports?
Date: Thu, 08 Apr 2004 03:29:37 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40752991.6020402@mlug.missouri.edu>
References: <41089CB27BD8D24E8385C8003EDAF7AB08484E@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBWnL-0002MN-La
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 03:30:03 -0700
Received: from outmta-1.esr.lvcm.net ([24.234.0.14])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBWnL-0002GX-B6
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 03:30:03 -0700
Received: from localhost (localhost [127.0.0.1])
	by outmta-1.esr.lvcm.net (Postfix) with ESMTP id C3E1A1C004F
	for <nfs@lists.sourceforge.net>; Thu,  8 Apr 2004 02:29:55 -0700 (PDT)
Received: from outmta-1.esr.lvcm.net ([127.0.0.1])
 by localhost (outmta-1.esr.lvcm.net [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 08070-18 for <nfs@lists.sourceforge.net>;
 Thu,  8 Apr 2004 02:29:55 -0700 (PDT)
Received: from mlug.missouri.edu (ip68-104-28-32.lv.lv.cox.net [68.104.28.32])
	by outmta-1.esr.lvcm.net (Postfix) with ESMTP id 54DE11C002E
	for <nfs@lists.sourceforge.net>; Thu,  8 Apr 2004 02:29:55 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <41089CB27BD8D24E8385C8003EDAF7AB08484E@karl.alexa.com>
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

Thanks everyone for the input. Based on your suggestions I quickly put 
together this rough shell script which seems to work. It correctly found 
every nfs server on my LAN and listed the exports each had.

---------------
#!/bin/bash

PORT='111'
NETWORK='192.168.1.0/24'

NMAP='/usr/bin/nmap'
SHOWMOUNT='/usr/sbin/showmount'

IPs=`$NMAP -PT$PORT $NETWORK | grep "Interesting ports on" | cut -d" " 
-f4 | cut -d":" -f1`

for IP in $IPs ; do
        $SHOWMOUNT -e $IP
done
---------------


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
