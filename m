From: Robert Rati <Robert.Rati@motorola.com>
Subject: Re: mountd through a firewall?
Date: Thu, 20 Feb 2003 11:48:59 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E55150B.1030201@motorola.com>
References: <Pine.LNX.4.44.0302201229340.9655-100000@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate.mot.com ([129.188.136.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18luof-0007f9-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 09:49:01 -0800
Received: from pobox.mot.com (pobox.mot.com [129.188.137.100])
	by motgate.mot.com (Motorola/Motgate) with ESMTP id h1KHmxcu015049
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 10:48:59 -0700 (MST)
Received: [from il02exm02.corp.mot.com (il02exm02.corp.mot.com [10.0.100.55]) by pobox.mot.com (MOT-pobox 2.0) with ESMTP id KAA27950 for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 10:48:59 -0700 (MST)]
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.44.0302201229340.9655-100000@guppy.limebrokerage.com>
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

>>I've tried using the -p option, but that causes mountd to try to open 
>>all 4 ports on the same port.  For the two UDP ports that not a problem 
>>(although I don't think functionally it'd work too well), but the two 
>>TCP ports obviously will have a problem.  When I run rpc.mountd -p 5000, 
>>I get this error:
>>
>>mountd: Could not bind name to socket: Address already in use
> 
> 
> Then you have a broken mountd.. because it doesn't need to listen on 
> multiple ports. You saw my rpcinfo output, even without -p it was only 
> using 2 distinct ports.
> 
> I just tested the mountd from both nfs-utils 0.3.3 and 1.0.1, both work 
> correctly with respect to -p.

rpc.mountd -version gives this info:

kmountd 1.4.7 (0.4.22)

and I don't have nfs-utils installed on the system.  I'm stuck using 
kernel 2.2.17 and I had read you had to have a 2.4 kernel to use 
nfs-utils.  Is that incorrect?  Is this possibly a limitation of the 
version of mountd on the system?

Rob



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
