From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Maximum number of nfsd daemons?
Date: Thu, 1 Aug 2002 14:27:03 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15688.47255.83237.874274@notabene.cse.unsw.edu.au>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17a7Y4-0003he-00
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 21:26:52 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <dbarbar@legato.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 1 Aug 2002 14:26:26 +1000
To: Daniel Barbar <dbarbar@legato.com>
In-Reply-To: message from Daniel Barbar on Wednesday July 31
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

On Wednesday July 31, dbarbar@legato.com wrote:
> Hi,
> 
>   We recently moved one of our NFS servers from a Sun machine running
> Solaris 7 to an Intel box running SuSE Linux 8.0 (kernel 2.4.18). We are
> experiencing some (rather heavy) performance problems, more so for clients
> accesing the service over our WAN link.
>   I'm starting to go through the excerise of tuning the NFS system, and
> started first by trying to increase the number of nfsd process. It seems
> that there is a hard coded limit of 128 processes, is that correct? If true,
> is it because one shouldn't expect any substantial performance increase by
> setting the number of nfsd threads to a number larger than 128?

This is correct in 2.4.18.  
2.4.18 will have a substantially larger limit.
Just change the #define in fs/nfsd/nfssvc.c and recompile for a larger
limit.

I guess when the number was chosen, computers were smaller.
It could be that more than 128 threads will help you, but it would be
worth checking 
   /proc/net/rpc/nfsd 
to see how many threads are really being used.  Send me the content of
that file and I will interpret bits for you.

NeilBrown



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
