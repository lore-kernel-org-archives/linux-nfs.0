From: Ion Badulescu <ionut@moisil.cs.columbia.edu>
Subject: Re: solaris server and firewalls
Date: Fri, 12 Sep 2003 08:29:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309121229.h8CCTWLR005929@buggy.badula.org>
References: <3F5C6375.9070907@clifford.net>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xn73-0003Wf-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 05:33:21 -0700
Received: from algx-tower-com-4173.z188-2-66.customer.algx.net ([66.2.188.62] helo=ns2.limegroup.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19xn73-0007lv-Ax
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 05:33:21 -0700
Received: from homeserver.limebrokerage.com (homeserver.limebrokerage.com [10.2.20.201])
	by ns2.limegroup.com (8.12.9/8.12.9) with ESMTP id h8CCXGO1020499
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 08:33:16 -0400
Received: from guppy.limebrokerage.com (guppy.limebrokerage.com [10.2.20.43])
	by homeserver.limebrokerage.com (8.12.9/8.12.9) with ESMTP id h8CCXGK6030730
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 08:33:16 -0400
Received: from guppy.limebrokerage.com (localhost. [127.0.0.1])
	by guppy.limebrokerage.com (8.12.9/8.12.9) with ESMTP id h8CCXFYH016473
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 08:33:15 -0400
Received: (from ion@localhost)
	by guppy.limebrokerage.com (8.12.9/8.12.9/Submit) id h8CCXFGE016471
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 08:33:15 -0400
To: Raphael Clifford <raphael@clifford.net>
In-Reply-To: <3F5C6375.9070907@clifford.net>
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

On Mon, 08 Sep 2003 12:09:41 +0100, Raphael Clifford <raphael@clifford.net> wrote:

> Is it safe to assume that
> 
> a) There is no solution for using linux with solaris nfs servers with 
> respect to the linux firewall and
> b) There is no project working on this problem?

What you need here is a mount program that understands WebNFS. No change 
is required for the kernel.

However, as far as I know there is no mount program for Linux that
supports WebNFS. Amd tried to implement it at some point, but the idea
quickly died off for lack of interest and users. Maybe I'll have another 
try at it some day, but if you're not using amd anyway then there is no 
point in wasting my time...

> If so, would it be a good idea to add this to the HOWTO?

Probably.

Ion
[amd co-maintainer]

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
