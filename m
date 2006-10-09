From: Neil Brown <neilb@suse.de>
Subject: Re: intermittent EPERM
Date: Mon, 9 Oct 2006 15:17:07 +1000
Message-ID: <17705.56147.148462.705488@cse.unsw.edu.au>
References: <1159961801.9991.11.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GWq77-0002qH-Kc
	for nfs@lists.sourceforge.net; Mon, 09 Oct 2006 01:03:53 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GWq78-0000Zg-7y
	for nfs@lists.sourceforge.net; Mon, 09 Oct 2006 01:03:54 -0700
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
In-Reply-To: message from Brian J. Murrell on Wednesday October 4
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday October 4, brian@interlinx.bc.ca wrote:
> Since having upgraded my Ubuntu (edgy) kernel I have noticed the last
> few revs of it cause intermittent EPERM errors on NFS clients.  For
> example:
> 
> brian@pc:~$ sudo mount pc:/home/brian /mnt/test
> brian@pc:~$ cd /mnt/test
> brian@pc:/mnt/test$ cat .bash_profile
> cat: .bash_profile: Permission denied
> brian@pc:/mnt/test$ cat .bash_profile
> cat: .bash_profile: Permission denied
> brian@pc:/mnt/test$ cat .bash_profile
> # .bash_profile
> 
> # Get the aliases and functions
> if [ -f ~/.bashrc ]; then
>         . ~/.bashrc
> fi
> 
> It took three attempts at reading that file to not get an EPERM.
> 
> Is this a known issue of any sort?

Yep.  It should be fixed in 2.6.18 and recent 2.6.17.x releases.
You can work-around by exporting with no_subtree_check (which is a
good idea anyway and will be the default one day soon).

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
