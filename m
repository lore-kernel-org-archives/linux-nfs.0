From: "Guolin Cheng" <guolin@alexa.com>
Subject: RE: auto-discovery of exports?
Date: Wed, 7 Apr 2004 16:01:39 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41089CB27BD8D24E8385C8003EDAF7AB08484E@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBM3B-0002Fu-60
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 16:01:41 -0700
Received: from birdwell-public.alexa.com ([67.107.182.10] helo=karl.presidio.alexa.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBM3B-0005dW-2T
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 16:01:41 -0700
To: "Michael" <mogmios@mlug.missouri.edu>,
	<nfs@lists.sourceforge.net>
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

Hi, Michael,

 Run shell command "showmount -e|--exports <server_to_be_questioned>".
If you would like to scan your network to check each host, run a for
loop, and in the loop put another command "rpcinfo -p
<server_to_be_questions>  |grep nfs" to make sure whether the nfs server
is running on the host, if so, run the showmount command to query the
exported file system from the host.=20

 Read manuals you will get more options, although the above should be
enough for your purposes.

 --Guolin Cheng


-----Original Message-----
From: Michael [mailto:mogmios@mlug.missouri.edu]=20
Sent: Wednesday, April 07, 2004 1:04 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] auto-discovery of exports?

Windows with the SFU add-on, allowing it to work as an NFS client,=20
manages to scan my network for NFS servers and then show the exported=20
filesystem under each of those servers. How could I implement the same=20
thing in Linux?

I ask because I want to write a program that autoscans my network for=20
certain files (images, music, video) that are readable and displays them

in a nice viewer to the user without needing to go searching for them. I

want the system to be flexible enough that it can allow machines to be=20
plugged in and out of the network and still detect those shared files=20
when available without any effort by the user.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=3D1470&alloc_id=3D3638&op=3Dcli=
ck
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
