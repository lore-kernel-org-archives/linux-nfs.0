From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: setting default permissions
Date: Fri, 13 Sep 2002 10:46:34 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15745.13674.55694.645325@notabene.cse.unsw.edu.au>
References: <5CE83B571395D311A2160008C7B12CDE17B523B8@ammex003.amp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17phrS-0000de-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Sep 2002 21:15:18 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28]:58833)
	by panoramix.vasoftware.com with smtp (Exim 4.05-VA-mm1 #1 (Debian))
	id 17peeQ-0005Sh-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Sep 2002 17:49:38 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <Travis.Smith@tycoelectronics.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Sep 2002 10:46:38 +1000
To: "Smith, Travis" <Travis.Smith@tycoelectronics.com>
In-Reply-To: message from Smith, Travis on Thursday September 12
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php=nfs>

On Thursday September 12, Travis.Smith@tycoelectronics.com wrote:
> Is there a way to specify the permissions on an exported directory beyond
> that of locking it down to certain machines/users.  What I want to do is
> export a directory from a linux box to some HP boxen and make sure that any
> file they write to the directory has full 777 permissions.  Security isn't
> an issue.
> 
> Thanks,
> Travis Smith

I see two options:

 1/ make everybody on HP boxen set
       umask 0

 2/ hack the sourcecode for the server.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
