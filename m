From: Ion Badulescu <ionut@badula.org>
Subject: Re: mountd through a firewall?
Date: Thu, 20 Feb 2003 13:22:58 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302201322341.9655-100000@guppy.limebrokerage.com>
References: <3E55150B.1030201@motorola.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ip64-48-93-2.z93-48-64.customer.algx.net ([64.48.93.2] helo=ns1.limegroup.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lvLn-00089N-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 10:23:15 -0800
To: Robert Rati <Robert.Rati@motorola.com>
In-Reply-To: <3E55150B.1030201@motorola.com>
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

> rpc.mountd -version gives this info:
> 
> kmountd 1.4.7 (0.4.22)

Ancient history.

> and I don't have nfs-utils installed on the system.  I'm stuck using 
> kernel 2.2.17 and I had read you had to have a 2.4 kernel to use 
> nfs-utils.  Is that incorrect?  Is this possibly a limitation of the 
> version of mountd on the system?

Incorrect, nfs-utils works with any 2.2 and newer kernel.

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
