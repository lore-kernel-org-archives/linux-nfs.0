From: David Ford <david+cert@blue-labs.org>
Subject: Re: NFS problems across reboot
Date: Sun, 07 Apr 2002 01:48:52 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAFEBD4.9030708@blue-labs.org>
References: <3CACA93C.5010304@blue-labs.org>	<3CAD6A78.4205CD61@moving-picture.com>	<3CAFCE8C.5030300@blue-labs.org>	<15535.55222.401084.736426@notabene.cse.unsw.edu.au> <15535.56536.237108.198660@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, James Pearson
 <james-p@moving-picture.com>
Received: from 60.54.252.64.snet.net
	([64.252.54.60] helo=hotmale.boyland.org ident=kaliuser)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16u6RT-0005ky-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 22:46:23 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

I'm not using XFS, I'm using NFS.  Originating filesystems are reiserfs 
and ext2, doesn't make a difference.

-d

Neil Brown wrote:

>On Sunday April 7, neilb@cse.unsw.edu.au wrote:
>
>>13 == EACCES.  Looks like the filesystem isn't exported.
>>
>>Show us the relevent /etc/init.d file.
>>My guess is that "exportfs -a" is being run *After* rpc.nfsd.
>>It must must run *before* for correct operation.
>>
>
>Actually, that would cause ESTALE, not EACCES.
>
>EACCES seems to suggest an XFS problem.
>Can you duplicate this without using XFS????
>
>NeilBrown
>
>>NeilBrown
>>
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
