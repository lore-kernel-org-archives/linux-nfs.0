From: Ion Badulescu <ionut@badula.org>
Subject: Re: solaris server and firewalls
Date: Tue, 23 Sep 2003 14:08:37 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309231406230.3991-100000@guppy.limebrokerage.com>
References: <3F706A27.3050302@clifford.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ion Badulescu <lists@cs.columbia.edu>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1ram-00024E-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Sep 2003 11:08:52 -0700
Received: from algx-tower-com-4173.z188-2-66.customer.algx.net ([66.2.188.62] helo=ns2.limegroup.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A1ral-0003LP-Mw
	for nfs@lists.sourceforge.net; Tue, 23 Sep 2003 11:08:51 -0700
To: Raphael Clifford <raphael@clifford.net>
In-Reply-To: <3F706A27.3050302@clifford.net>
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

On Tue, 23 Sep 2003, Raphael Clifford wrote:

> That is fantastic news.  Just out of interest, who should I bug about 
> mount? I couldn't seem to find a suitable maintainer listed anywhere.

>From /usr/share/doc/util-linux-xxx/README.mount:

mount/umount for Linux 0.97.3 and later.
Authors:
Doug Quale <quale@saavik.cs.wisc.edu>,
H.J. Lu <hlu@eecs.wsu.edu>,
Rick Sladkey <jrs@world.std.com>,
Stephen Tweedie <sct@dcs.ed.ac.uk>.

Presently maintained by Andries Brouwer <aeb@cwi.nl>.
Ftp site: ftp.win.tue.nl:/pub/linux/utils/util-linux


Red Hat separates mount from util-linux in their RPM's, but they come from 
the same package (util-linux) originally.

Ion

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
