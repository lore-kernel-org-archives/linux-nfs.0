From: Alan Powell <lakerfaniam2@yahoo.com>
Subject: RE: iostat wkB/s numbers during testing
Date: Fri, 14 Feb 2003 09:35:24 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030214173524.67891.qmail@web12205.mail.yahoo.com>
References: <6440EA1A6AA1D5118C6900902745938E07D552E3@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web12205.mail.yahoo.com ([216.136.173.89])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jjkD-00030d-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 09:35:25 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>,
  Paul Heinlein <heinlein@cse.ogi.edu>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D552E3@black.eng.netapp.com>
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

If you do lots of writes, it's especially important
that you enable the RAID controllers write-back cache
(if you're concerned about data loss in case of power
failure, you can get battery backup for most cards for
a little more than $100). Also, ideally you'd try to
keep write-intensive stuff on a RAID-1 partition, and
the rest on RAID-5, b/c RAID-5 is _very_ inefficient
at writes. If you have 6 drives, why don't you set 2
of them aside for RAID-1 and the most write-intensive
files?


--- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
> hi paul-
> 
> you can check the list archives for more
> information,
> but the experiences on this list have been that RAID
> 5 is generally not a hi-performance back-end
> solution
> for Linux NFS servers.
> 
> i believe the problem is that NFS servers generate
> lots
> of small writes, and that's something RAID 5 is not
> very good at.
> 
> i can't answer your specific question about the
> numbers
> you posted.  maybe someone else?
> 
> > -----Original Message-----
> > From: Paul Heinlein [mailto:heinlein@cse.ogi.edu] 
> > Sent: Friday, February 14, 2003 10:32 AM
> > To: nfs@lists.sourceforge.net
> > Subject: [NFS] iostat wkB/s numbers during testing
> > 
> > 
> > I'm using a dual P-III Compaq DL380 running Red
> Hat 8.0 to 
> > host a new ATABoy RAID array purchased from
> Nexsan. It's 
> > connected to our switch via a gig/fiber card based
> on the 
> > Intel 82542 chipset.
> > 
> > The service stack (for lack of a better phrase) is
> > 
> > * ATABoy2 -- six-drive RAID-5 array that presents
> itself to the host 
> >              as a single SCSI device (no multiple
> LUNs)
> > * LVM     -- 1.0.3, one PV, one VG, one LV (so far
> :-)
> > * XFS     -- 1.2pre5
> > * NFS     -- v2/v3, UDP only, 80 nfsd threads
> > * Samba   -- 2.2.7
> > 
> > Last night, I set up six NFS clients and one
> Linux/smbfs 
> > client to run 
> > iozone against the nfs mount/samba share.
> > 
> > I was keeping track of stats using iostat -x on
> the server. 
> > My typical wkB/s numbers hovered in the 15000 to
> 19000 range. 
> > Is that sort of result set consistent with what
> any of you 
> > have seen for Linux-hosted 
> > NFS RAID exports?
> > 
> > --Paul Heinlein <heinlein@cse.ogi.edu>
> > 
> > 
> > 
> >
>
-------------------------------------------------------
> > This SF.NET email is sponsored by: FREE  SSL Guide
> from 
> > Thawte are you planning your Web Server Security?
> Click here 
> > to get a FREE Thawte SSL guide and find the
> answers to all 
> > your  SSL security issues. 
> > http://ads.sourceforge.net/cgi->
> bin/redirect.pl?thaw0026en
> > 
> > 
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net 
> > https://lists.sourceforge.net/lists/listinfo/n> fs
> > 
> 
> 
>
-------------------------------------------------------
> This SF.NET email is sponsored by: FREE  SSL Guide
> from Thawte
> are you planning your Web Server Security? Click
> here to get a FREE
> Thawte SSL guide and find the answers to all your 
> SSL security issues.
>
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


__________________________________________________
Do you Yahoo!?
Yahoo! Shopping - Send Flowers for Valentine's Day
http://shopping.yahoo.com


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
