From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: exportfs nohide option for nfsv4
Date: Thu, 10 Mar 2005 07:14:50 -0800 (PST)
Message-ID: <20050310151451.84319.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9PNM-0008Aq-R7
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 07:15:00 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D9PNL-0002cH-6Q
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 07:15:00 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: 6667
Sender: nfs-admin@lists.sourceforge.net
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

what i feel is that when i have explicitly exported 
exported /export/exp1 and /export i should not require
to specify no hide option(I have explicitly exported
/export/exp1 and so why should i ask nfs to
unhide it)

   I am referring to  man page of exports.
 Please let me know if i am wrong.
thanks,
 -- kiran


--- "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Mar 10, 2005 at 04:07:22AM -0800, mehta
> kiran wrote:
> > Hi , 
> >         I am using RHEL 4 GA.
> >         i created directories /export ,
> /export/exp1.
> >         Then i started all the nfs daemons.
> >         I mounted a disk on /export/exp1.
> > 
> >         Then i exported /export using
> >         exportfs -o rw,no_root_squash,fsid=0
> *:/export
> > 
> >         I exported /export/exp1 using
> >        exportfs -o rw,no_root_squash
> *:/export/exp1
> > 
> >       I mounted exported fs on client side using
> >       mount -t nfs4 server:/  /share
> > 
> >       but i am not able to see contents of
> /share/exp1
> >       When i used nohide attribute for exporting
> fs 
> >       then everyting works fine.
> > 
> >       As per man page , nohide is not needed if 
> the
> >       filesystems mounted on child directories are
> >       exported.
> >       Please let me know if i ma wrong
> 
> Could you point out which part of which manpage
> you're referring to?
> 
> The nohide option *is* (as you've seen) required in
> this case.  (Well,
> either that or "crossmnt" on the parent export.)
> 
> --b.
> 
> 
>
-------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT
> Products from real users.
> Discover which products truly live up to the hype.
> Start reading now.
>
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


		
__________________________________ 
Do you Yahoo!? 
Make Yahoo! your home page 
http://www.yahoo.com/r/hs


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
