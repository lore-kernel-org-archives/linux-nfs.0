From: Ian Kent <raven@themaw.net>
Subject: RE: nfs hang, acutaully really slow
Date: Fri, 7 May 2004 12:35:34 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405071231551.8952@wombat.indigo.net.au>
References: <482A3FA0050D21419C269D13989C61130435DFDC@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Maxwell Bottiger <sleepylight@jive-turkey.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLwxc-0005WB-2t
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 21:27:44 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BLwxb-0001w0-Fr
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 21:27:43 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DFDC@lavender-fe.eng.netapp.com>
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

On Thu, 6 May 2004, Lever, Charles wrote:

> hi maxwell-
> 
> > 	I'm running some version of NFSv3.  I have whatever 
> > came packaged 
> > along with Fedora Core 1.  (They put their own version number on the 
> > package)
> > 
> > 	My server appears to be running into a real problem transfering 
> > files.  As long as my transfers are super small (like ls) 
> > then everything 
> > is cool.  As soon as I try to work on bigger files (greater 
> > than 4k) most 
> > everything grinds to a screetching halt.  I can see that 
> > there is still 
> > activity, but the transfers are in terms of 3 or 4 packets every few 
> > seconds.  I've sort of been hobbling along using scp (wich is runing 
> > somewhere between 1000x to 1000000x faster than NFS right 
> > now) but that 
> > only works for so long.
> > 
> > 	Where do I start trying to solve this problem?  I haven't been 
> > able to find any error messages.  Any help is greatly appreciated.
> 
> these are the classic symptoms of a network issue; probably
> a speed or duplex mismatch in the network between your clients
> and server.  if you switch to NFS over TCP, the problem will
> likely go away.

Are you sure about that?

When I've had problems with link negotiation it's has been essential to 
get the speed and duplex to match the switch. Performance overall is 
significantly affected if you don't. 

Ian



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
