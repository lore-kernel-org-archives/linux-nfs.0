From: eric whiting <ewhiting@amis.com>
Subject: Re: Maximum number of nfsd daemons?
Date: Wed, 31 Jul 2002 22:28:45 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D48B8FD.2A5094@amis.com>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 154-100.poccpe.cableone.net ([24.116.154.100] helo=gannett.design.amis.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17a7b8-0003wU-00
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 21:30:02 -0700
To: Daniel Barbar <dbarbar@legato.com>
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

What OS are the clients running?  If they are solaris boxes you might
want to consider the NFS/TCP patches for the linux NFS server -- NFS/UDP
over a WAN can have problems. TCP might help out some.
eric



Daniel Barbar wrote:
> 
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
>   Thanks in advance for your help. Regards,
> 
> ---
> Daniel Barbar
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: Dice - The leading online job board
> for high-tech professionals. Search and apply for tech jobs today!
> http://seeker.dice.com/seeker.epl?rel_code=31
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
