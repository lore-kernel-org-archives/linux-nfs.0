From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: RE: iostat wkB/s numbers during testing
Date: Fri, 14 Feb 2003 09:49:05 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302140942460.20965-100000@glenfiddich.cse.ogi.edu>
References: <20030214173524.67891.qmail@web12205.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from franklin.cse.ogi.edu ([129.95.40.9])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jjxX-00056g-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 09:49:11 -0800
To: Alan Powell <lakerfaniam2@yahoo.com>
In-Reply-To: <20030214173524.67891.qmail@web12205.mail.yahoo.com>
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

On Fri, 14 Feb 2003, Alan Powell wrote:

> If you do lots of writes, it's especially important that you enable
> the RAID controllers write-back cache

The ATABoy ships with a 128MB write cache, enabled by default.

> Also, ideally you'd try to keep write-intensive stuff on a RAID-1
> partition, and the rest on RAID-5, b/c RAID-5 is _very_ inefficient
> at writes. If you have 6 drives, why don't you set 2 of them aside
> for RAID-1 and the most write-intensive files?

The filesystem we're exporting is for general-purpose use and is
directory-divided among a number of customer groups.  If I were
setting the export up for a specific application, then your suggestion
would make a whole lotta sense. I'll certainly keep it in mind if one
or more customers have specific complaints about write performance.

--Paul Heinlein <heinlein@cse.ogi.edu>



-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
