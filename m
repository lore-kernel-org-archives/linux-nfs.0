From: "Guolin Cheng" <guolin@alexa.com>
Subject: RE: auto-discovery of exports?
Date: Wed, 7 Apr 2004 18:44:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41089CB27BD8D24E8385C8003EDAF7AB084850@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "Michael" <mogmios@mlug.missouri.edu>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOb4-0005cP-Rr
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:44:50 -0700
Received: from birdwell-public.alexa.com ([67.107.182.10] helo=karl.presidio.alexa.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOb3-00051u-L5
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:44:49 -0700
To: "Ian Kent" <raven@themaw.net>
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

Sure, to your own networks, do you want to search all Internet for nfs
servers? :)

Run a "nmap -sU -p 2049 <your_net_work, like 192.168.0>" to find all nfs
servers providing services on UDP, similar "nmap -p 2049 <your_net_work,
like 192.168.0>" to find nfs servers on TCP.

Then for each above hosts, run the showmount command. All these can be
rolled in a simple loop with a if statement.

Thanks.
--Guolin Cheng

-----Original Message-----
From: Ian Kent [mailto:raven@themaw.net]=20
Sent: Wednesday, April 07, 2004 5:37 PM
To: Guolin Cheng
Cc: Michael; nfs@lists.sourceforge.net
Subject: RE: [NFS] auto-discovery of exports?

On Wed, 7 Apr 2004, Guolin Cheng wrote:

> Hi, Michael,
>=20
>  Run shell command "showmount -e|--exports <server_to_be_questioned>".
> If you would like to scan your network to check each host, run a for
> loop, and in the loop put another command "rpcinfo -p
> <server_to_be_questions>  |grep nfs" to make sure whether the nfs
server
> is running on the host, if so, run the showmount command to query the
> exported file system from the host.=20

Fine but how would you enumerate the hosts?
Would you restrict this to the local subnet?

Ian





-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
