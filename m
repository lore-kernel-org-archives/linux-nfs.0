From: "Wendy Cheng" <s_wendy_cheng@hotmail.com>
Subject: NFS UDP fragmentation
Date: Fri, 27 Feb 2004 05:27:19 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY2-F35JXDq1Tj6uZv0000dcd8@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwaZG-0005qB-R4
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 21:29:46 -0800
Received: from bay2-f35.bay2.hotmail.com ([65.54.247.35] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AwaX3-0001an-JE
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 21:27:29 -0800
To: nfs@lists.sourceforge.net
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

Hi,

We're debugging an UDP packet fragmentation problem that leads us to the 
nfs.sourceforge.net FAQ (http://nfs.sourceforge.net/#section_b). In section 
B10, it is stated that

"The fix is to make the Linux's IP fragmentation logic continue fragmenting 
a datagram even when output socket buffer space is over its limit. This fix 
appears in kernels newer than 2.4.20.".

And

"3. If you can't upgrade your clients, increase the default size of your 
client's socket buffers (see below). 2.4.20 and later kernels do this 
automatically for the NFS client's socket buffers. See Section 5.3ff of the 
NFS How-To for more information."

We're wondering where exactly these two pieces of code located (in 
$2.4.21kernel/fs/nfs directory ?) Since our system is based on one 
particular vendor's distribution, we would like to do a "diff" to check 
whether they're included.

Could folks give us a hand ? Great thanks !

-- Wendy

_________________________________________________________________
Watch high-quality video with fast playback at MSN Video. Free! 
http://click.atdmt.com/AVE/go/onm00200365ave/direct/01/



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
