From: Jose Santiago <jsantiago@chrysalisdev.com>
Subject: Re: getfh failed: Operation not permitted
Date: Tue, 13 Aug 2002 09:26:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D591706.6000900@chrysalisdev.com>
References: <3D58106F.1030809@chrysalisdev.com> <20020813133428.GA2393@farm.ecs.umass.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 89.levincom.com ([198.78.56.89] helo=chrysalis-sbs1.chrysalisdev.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eccr-0005S3-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 07:26:25 -0700
To: Tim Middelkoop <mtim@farm.ecs.umass.edu>
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

That Fixed the Problem. Thank You.

Tim Middelkoop wrote:

> [SNIP]
> 
> Fought with this for a long time...  I don't think nfs likes mixing
> dns and ip exports... I also zaped some stuff in /var/lib/nfs after
> taking down the server and fixing the mixed ip/name stuff... have not
> had a problem since.. (I think it is a case of having old stuff haning
> arround in /var/lib/nfs
> 
> hope this helps, tim...




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
