From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: auto-discovery of exports?
Date: Thu, 08 Apr 2004 12:02:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4074B2BD.7936CF93@melbourne.sgi.com>
References: <41089CB27BD8D24E8385C8003EDAF7AB084850@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, Michael <mogmios@mlug.missouri.edu>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOsg-0003y7-S3
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 19:03:02 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOsg-0001OA-In
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 19:03:02 -0700
To: Guolin Cheng <guolin@alexa.com>
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

Guolin Cheng wrote:
> 
> Sure, to your own networks, do you want to search all Internet for nfs
> servers? :)
> 
> Run a "nmap -sU -p 2049 <your_net_work, like 192.168.0>" to find all nfs
> servers providing services on UDP, similar "nmap -p 2049 <your_net_work,
> like 192.168.0>" to find nfs servers on TCP.

You shouldn't rely on port 2049 for pre-v4 NFS.  To enumerate NFS servers
try doing a broadcast RPC of a NULL call to RPC program 100003.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
