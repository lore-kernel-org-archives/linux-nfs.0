From: Phy Prabab <phyprabab@yahoo.com>
Subject: RE: mtab and procs not in sync?
Date: Tue, 8 Jun 2004 13:31:26 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040608203126.88334.qmail@web51801.mail.yahoo.com>
References: <482A3FA0050D21419C269D13989C61130435E229@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXnFz-0008Fg-2q
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 13:31:39 -0700
Received: from web51801.mail.yahoo.com ([206.190.38.232])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BXnFw-0003nV-D3
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 13:31:36 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E229@lavender-fe.eng.netapp.com>
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

okay, how about many more mounts in mtab but not in
proc/mounts?  cat of proc/mounts shows 10 mount
points, mtab show 23.  I am guessing a bug? 

Thank you for your time.
Phy

--- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
> if there are a lot of mounts on the system, then
> /proc/mounts can be
> truncated and not show all of them.
> 
> however, if there are more mounts in /proc/mounts
> than in /etc/mtab,
> there is probably a bug in mount.  not unheard of.
> 
> > -----Original Message-----
> > From: Phy Prabab [mailto:phyprabab@yahoo.com] 
> > Sent: Tuesday, June 08, 2004 2:21 PM
> > To: nfs@lists.sourceforge.net
> > Subject: [NFS] mtab and procs not in sync?
> > 
> > 
> > Hello,
> > 
> > Have run into a situation where mtab does not
> match
> > /proc/mounts in that mtab has numerous entries
> that
> > have expired off and removed, yet does not show
> that
> > it has been removed from mtab.  Is this known and
> is
> > there a fix?
> > 
> > Kernel 2.4.21 and 23
> > nfs-utils 1.06
> > automount 4.1.2
> > 
> > Thanks!
> > Phy
> > 
> > 
> > 	
> > 		
> > __________________________________
> > Do you Yahoo!?
> > Friends.  Fun.  Try the all-new Yahoo! Messenger.
> > http://messenger.yahoo.com/ 
> > 
> > 
> >
>
-------------------------------------------------------
> > This SF.Net email is sponsored by: GNOME
> Foundation
> > Hackers Unite!  GUADEC: The world's #1 Open Source
> Desktop Event.
> > GNOME Users and Developers European Conference,
> 28-30th June in Norway
> > http://2004/guadec.org
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
