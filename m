From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: RE: Performance Woes...
Date: Thu, 13 Jun 2002 14:16:15 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15624.7311.559630.276732@notabene.cse.unsw.edu.au>
References: <F888C30C3021D411B9DA00B0D0209BE8038F9523@cvo-exchange.cvo.roguewave.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17IM1O-0004c8-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 21:15:43 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <petersp@roguewave.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 13 Jun 2002 14:15:26 +1000
To: Poul Petersen <petersp@roguewave.com>
In-Reply-To: message from Poul Petersen on Wednesday June 5
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

On Wednesday June 5, petersp@roguewave.com wrote:
> >   while : ; do netstat -n -u -a | grep :2049 ; sleep 1; done
> > 
> > I get:
> > udp      348      0 0.0.0.0:2049            0.0.0.0:*         
> >                   
> >                   
> > udp     2436      0 0.0.0.0:2049            0.0.0.0:*         
> >                   
> >        ^^^^^^
> > 
> > Note this column of numbers.  If it hits a ceiling at 65536, you have
> > a problem that can be fixed.  See the NFS FAQ, or show me the numbers
> > and I will explain.
> 
> 	Interesting - In the half hour or so that I've watched our NFS
> server, this number has hit 65406. It isn't clear to me what section of the
> NFS FAQ (http://nfs.sourceforge.net/) is relevant to this test. 

5.4. Memory Limits on the Input Queue

NeilBrown

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
