From: Tiziano Zito <t.zito@biologie.hu-berlin.de>
Subject: Re: NFS server hangs when user hits hard quota
Date: Mon, 12 Mar 2007 10:16:32 +0100
Message-ID: <20070312091632.GA9603@lotka.biologie.hu-berlin.de>
References: <20070307140143.GA20450@lotka.biologie.hu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQgeK-0008EE-Ek
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 02:17:00 -0700
Received: from suncom3.cms.hu-berlin.de ([141.20.1.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQgeK-0002XL-SM
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 02:17:02 -0700
In-Reply-To: <20070307140143.GA20450@lotka.biologie.hu-berlin.de>
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

Hi all! from the lack of response I have to conclude that this is
*our* problem and not nfs'. I've tried installing a new server but
the problem remains. Really no one else has experienced such problems?
I found a patch against kernel 2.4.4 (May 7, 2001) by the Linux NFS
Client Performance Project
http://www.citi.umich.edu/projects/nfs-perf/patches/nfs-write-tuning1.diff
which removes the checks for hitting hard and soft limits when
writing. The patch appears to be integrated in the code base,
because grepping through the linux/fs/nfs source for 'hard limit'
only yields lines in pagelist.c. I don't know NFS internals enough
to say if this may be the cause of our problem. 

No one about this?

Thank you!

tiziano


On Wed 07 Mar, 15:01, Tiziano Zito wrote:
> Hi all! We are experiencing a problem with our nfs3 server
> running a debian stable (sarge) kernel 2.4.32. 
> When a program running on a client hits the user hard quota, the
> server becomes really slow and almost unresponsive. This is easily
> reproducible: on a client as a user with quota enabled do
> cp /dev/zero /path/with/quota/enabled 
> as soon as the user hits her/his hard limit the server chokes.
> The only way to solve the problem is to disconnect the client from
> the network and kill the offending process. 
> I would think that such things should not happen, otherwise any user
> could at anytime issue a DoS attack on the NFS server. I've seen
> other posts relating to the same subject on this list:
> 
> http://thread.gmane.org/gmane.linux.nfs/159
> http://thread.gmane.org/gmane.linux.nfs/216
> http://thread.gmane.org/gmane.linux.nfs/2988
> http://thread.gmane.org/gmane.linux.nfs/3938
> 
> What I can understand from this posts is that the problem was
> present and that no solution existed, at least 3 years ago.
> Is the situation in the meanwhile changed? Could a kernel upgrade or
> an NFS3 -> NFS4 migration solve the problem?
> 
> Thank you very much for any response, at the moment we are really
> stuck.
> 
> PS: please include me in the Cc, I'm not a subscriber of this list.
> 
> 
>  Tiziano Zito
>  Institute for Theoretical Biology
>  Humboldt-Universitaet zu Berlin  
>  Invalidenstrasse, 43
>  D-10115 Berlin, Germany
>  
>  room: 1306
>  phone: +49 30 2093-8630
>  fax:   +49 30 2093-8801
> 
> 
> 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
