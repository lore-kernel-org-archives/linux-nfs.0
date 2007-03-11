From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Re: RPCGSSD and root on Linux client
Date: Sat, 10 Mar 2007 16:43:04 -0800
Message-ID: <01AE8AF878612047A442668306EAEB055C4663@SACEXMV01.hq.netapp.com>
References: <01AE8AF878612047A442668306EAEB055C44F8@SACEXMV01.hq.netapp.com>
	<01AE8AF878612047A442668306EAEB055C4516@SACEXMV01.hq.netapp.com>
	<4d569c330703090724j2bcad85ayca0a383f9ec712f1@mail.gmail.com>
	<4d569c330703090814mae7f6b7hd494e89b5d46b77b@mail.gmail.com>
	<20070310170412.GB29710@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Burlyga, Alex" <Alex.Burlyga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQC9r-0007TY-Av
	for nfs@lists.sourceforge.net; Sat, 10 Mar 2007 16:43:31 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQC9s-0005SC-DV
	for nfs@lists.sourceforge.net; Sat, 10 Mar 2007 16:43:33 -0800
In-Reply-To: <20070310170412.GB29710@fieldses.org>
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

Gssd just wants any valid cred.  I'm guessing the '-m' author chose
nfs[/host]@REALM because they were pretty sure that if you were doing an
NFS mount that you'd have the nfs service cred :-)  But the current code
that makes the (once optional) '-m' behavior always on, thus always
hijacking root, is a problem (imo).

  -Dan

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Saturday, March 10, 2007 9:04 AM
To: Kevin Coffman
Cc: Muntz, Daniel; Burlyga, Alex; nfs@lists.sourceforge.net
Subject: Re: [NFS] RPCGSSD and root on Linux client

On Fri, Mar 09, 2007 at 11:14:05AM -0500, Kevin Coffman wrote:
> After thinking about this a bit more, I have a concern.
> 
> Let's say root authenticates as "foo@REALM" and begins accessing NFS 
> files using those credentials.  Some time later, the context expires 
> or must be recreated for some reason and root's credentials cache is 
> now either expired or has been destroyed.  The initial context 
> creation will fail and we will fall back and use the machine 
> credentials to create the new context.  This will cause confusion 
> because all of the sudden root is "nfs/<machine>@REALM" rather than 
> "foo@REALM".
> 
> Any suggestions on a way around this?

We might want to make sure this behavior is optional somehow--it could
be the reason they have an nfs/host@REALM cred is because the host is
also an NFS server, not because they want the client using it for root.

Given that, if  a user/administrator sets things up to allow gssd to
fall back on a different credential, then, well, that's what they asked
for....

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
