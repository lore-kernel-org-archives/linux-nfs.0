From: Yu Chen <chen@hhmi.umbc.edu>
Subject: Re: Darwin nfs mounting question?
Date: Tue, 23 Jul 2002 10:52:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SGI.4.44.0207231048590.14795-100000@cobalt.hhmi.umbc.edu>
References: <3D3D6B53.93B57B5@moving-picture.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zinc.hhmi.umbc.edu ([130.85.139.230])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X11P-0007oB-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 07:52:20 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3D3D6B53.93B57B5@moving-picture.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Yeah, I did re-export the file system, and set the appropriate permission.

Thanks.

On Tue, 23 Jul 2002, James Pearson wrote:

> Did you re-export the file system after changing from XFS to Reiserfs?
>
> James Pearson
>
> Yu Chen wrote:
> >
> > Dear all;
> >
> > I am tring to mount disks over nfs on Darwin, but failed. Any helps would
> > be highly appreciated. Here are my information:
> >
> > I was able to nfs mount the disk on Darwin when the nfs disk was in XFS
> > file system. Then we formated the disk as ReiserFs file system,and changed
> > nothing else. The automount seems work fine on Darwin, it doesn't give any
> > error message when started, but when I try to 'cd' to the directory, it
> > gives me error message saying:" Operation not permitted".
> >
> > Anyone has any suggestions? Thanks in advance for the helps!
> >
> > ===========================================
> > Yu Chen
> > Howard Hughes Medical Institute
> > University of Maryland Baltimore County
> > 1000 Hilltop Circle
> > Baltimore, MD 21250
> >
> > phone: (410)455-6347
> > fax: (410)455-1174
> > email: chen@hhmi.umbc.edu
> > ===========================================
> >
> > -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
