From: Robert Rati <Robert.Rati@motorola.com>
Subject: Re: mountd through a firewall?
Date: Thu, 20 Feb 2003 11:27:56 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E55101C.2030109@motorola.com>
References: <Pine.LNX.4.44.0302201208140.9655-100000@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate.mot.com ([129.188.136.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18luUM-0002br-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 09:28:02 -0800
Received: from pobox3.mot.com (pobox3.mot.com [10.64.251.242])
	by motgate.mot.com (Motorola/Motgate) with ESMTP id h1KHS1cu008796
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 10:28:01 -0700 (MST)
Received: [from il02exm02.corp.mot.com (il02exm02.corp.mot.com [10.0.100.55]) by pobox3.mot.com (MOT-pobox3 2.0) with ESMTP id KAA26793 for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 10:26:28 -0700 (MST)]
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.44.0302201208140.9655-100000@guppy.limebrokerage.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>Is there a way to control the port range mountd will use?  If not, do 
>>you know the range mountd will use?
> 
> 
> man rpc.mountd, look for "-p".

I've tried using the -p option, but that causes mountd to try to open 
all 4 ports on the same port.  For the two UDP ports that not a problem 
(although I don't think functionally it'd work too well), but the two 
TCP ports obviously will have a problem.  When I run rpc.mountd -p 5000, 
I get this error:

mountd: Could not bind name to socket: Address already in use

pmap_dump shows this:

     100005    1   udp   5000  mountd
     100005    1   tcp   5000  mountd
     100005    2   udp   5000  mountd

However, mountd is not running on the system even though it has 
registered ports with portmapper.  Can I specify a range of ports 
somehow?  I tried rpc.mountd -p5000:5002, but that didn't change anything.

Rob



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
