From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: query
Date: Wed, 22 Oct 2003 12:53:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16277.61735.731705.976287@notabene.cse.unsw.edu.au>
References: <NGBBKDKMALCPDNMIPMPLKENFCAAA.sundar@cdacb.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ACSls-0000ek-00
	for <nfs@lists.sourceforge.net>; Wed, 22 Oct 2003 16:52:09 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ACRx0-0004un-VK
	for nfs@lists.sourceforge.net; Wed, 22 Oct 2003 15:59:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24]:59232)
	by externalmx.vasoftware.com with smtp (Exim 4.22 #1 (Debian))
	id 1AC9mE-0005nK-Mn
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 20:35:14 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <sundar@cdacb.ernet.in>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Wed, 22 Oct 2003 12:53:31 +1000
To: "Sundareswar Jayakumar" <sundar@cdacb.ernet.in>
In-Reply-To: message from Sundareswar Jayakumar on Tuesday October 21
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tuesday October 21, sundar@cdacb.ernet.in wrote:
> Hi,
> 	I am working on adistributed filesytem on linux.I am using
> nfs source code as a learning resource.I require a clarification.
> 
> 
> In many entry points the Big Kernel Lock lock/unlock_kernel is
> used instead of locking just the private data structures of the
> filesystem.why is it so?.kindly clarify w.r.t to a smp m/c.

Because tghe BKL was the easiest way to make it work under SMP, and
the process of refining the locks hasn't made it into 2.4.

The 2.6.0 kernel does not use the BKL for nfsd at all, and I have
patches that remove the BKL for 2.4 but marcelo didn't want them when
I offered them some months ago, and I haven't offered again since.

NeilBrown

> 
> Thanks
> sundar
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by OSDN developer relations
> Here's your chance to show off your extensive product knowledge
> We want to know what you know. Tell us and you have a chance to win $100
> http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
