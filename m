From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: fsid syntax
Date: Wed, 7 Aug 2002 22:19:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020807221938.A26110@redhat.com>
References: <200208071711.00712.bernd-schubert@web.de> <shsk7n2d70y.fsf@charged.uio.no> <200208071830.54734.bernd-schubert@web.de> <15697.33669.398331.848444@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernd Schubert <bernd-schubert@web.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ccto-0000gM-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 19:19:40 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15697.33669.398331.848444@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Thu, Aug 08, 2002 at 06:31:01AM +1000
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

On Thu, Aug 08, 2002 at 06:31:01AM +1000, Neil Brown wrote:
> (*)  I really don't think that basing the fsid on the device number is
> at all sensible.  Afterall, that is what we are trying to avoid.
> Just pick a number, any number.
> 1 for the first filesystem, 2 for the second.
> Your age for the filesystem storing you home directory.
> 42 for the filesystem storing the Great Question of Life, The
> Universe, and Everything.

It would make sense for filesystems that have a GUID, like ext2/3, 
for it to be used as the fsid.  Just a thought.

		-ben


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
