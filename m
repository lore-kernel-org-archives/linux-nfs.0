From: Ion Badulescu <ionut@badula.org>
Subject: Re: mountd through a firewall?
Date: Thu, 20 Feb 2003 12:35:35 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302201229340.9655-100000@guppy.limebrokerage.com>
References: <3E55101C.2030109@motorola.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ip64-48-93-2.z93-48-64.customer.algx.net ([64.48.93.2] helo=ns1.limegroup.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lubs-00047p-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 09:35:48 -0800
To: Robert Rati <Robert.Rati@motorola.com>
In-Reply-To: <3E55101C.2030109@motorola.com>
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

On Thu, 20 Feb 2003, Robert Rati wrote:

> I've tried using the -p option, but that causes mountd to try to open 
> all 4 ports on the same port.  For the two UDP ports that not a problem 
> (although I don't think functionally it'd work too well), but the two 
> TCP ports obviously will have a problem.  When I run rpc.mountd -p 5000, 
> I get this error:
> 
> mountd: Could not bind name to socket: Address already in use

Then you have a broken mountd.. because it doesn't need to listen on 
multiple ports. You saw my rpcinfo output, even without -p it was only 
using 2 distinct ports.

I just tested the mountd from both nfs-utils 0.3.3 and 1.0.1, both work 
correctly with respect to -p.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
