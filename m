From: James Pearson <james-p@moving-picture.com>
Subject: Re: Darwin nfs mounting question?
Date: Tue, 23 Jul 2002 15:42:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D3D6B53.93B57B5@moving-picture.com>
References: <Pine.SGI.4.44.0207230957070.14795-100000@cobalt.hhmi.umbc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X0sX-0005qf-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 07:43:09 -0700
To: Yu Chen <chen@hhmi.umbc.edu>
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

Did you re-export the file system after changing from XFS to Reiserfs?

James Pearson

Yu Chen wrote:
> 
> Dear all;
> 
> I am tring to mount disks over nfs on Darwin, but failed. Any helps would
> be highly appreciated. Here are my information:
> 
> I was able to nfs mount the disk on Darwin when the nfs disk was in XFS
> file system. Then we formated the disk as ReiserFs file system,and changed
> nothing else. The automount seems work fine on Darwin, it doesn't give any
> error message when started, but when I try to 'cd' to the directory, it
> gives me error message saying:" Operation not permitted".
> 
> Anyone has any suggestions? Thanks in advance for the helps!
> 
> ===========================================
> Yu Chen
> Howard Hughes Medical Institute
> University of Maryland Baltimore County
> 1000 Hilltop Circle
> Baltimore, MD 21250
> 
> phone: (410)455-6347
> fax: (410)455-1174
> email: chen@hhmi.umbc.edu
> ===========================================
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
