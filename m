From: bob@proulx.com (Bob Proulx)
Subject: Re: Annoying rename() problem
Date: Fri, 27 Oct 2006 23:09:07 -0600
Message-ID: <20061028050907.GB22175@dementia.proulx.com>
References: <003f01c6f54a$90506250$020010ac@athlon64>
	<20061024160932.GB17308@dementia.proulx.com>
	<20061026025120.GA12505@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdgwU-0000Lh-E2
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 22:41:14 -0700
Received: from joseki.proulx.com ([216.17.153.58])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdgwT-0000Hn-NS
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 22:41:15 -0700
Received: from dementia.proulx.com (dementia.proulx.com [192.168.1.115])
	by joseki.proulx.com (Postfix) with ESMTP id B8C2D4B2E8
	for <nfs@lists.sourceforge.net>; Fri, 27 Oct 2006 23:09:05 -0600 (MDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061026025120.GA12505@fieldses.org>
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

J. Bruce Fields wrote:
> I'd have guessed the client is replaying the rename request and only
> seeing the reply to the second attempt (even though the first also
> succeeded).

That is possible.  In a busy network environment it would be possible
for the udp packets to be duplicated.  If the nfs system did not
handle this duplication then it could be fooled into thinking it had
failed when it had not.  But I thought that nfs handled udp with
checksumming and retries, no?

> Are you using tcp?

I am using udp.  I don't know about the OP.

> (And if not, does switching help?)

I don't know if switching to tcp would help.  For various reasons I
can't really make that change at this time.

> Does adjusting the timeout times (see timeo, retrans in "man nfs")
> help?

Various people in my lab have tried an assortment of nfs timeout and
retransmit options, with regards to nfs performance, not to this
particular problem.

I don't know if the original poster Antoniu-George SAVU will be able
to benefit from the suggestions here.  In my case the problem is
already worked around with code changes in the application.  Therefore
my test case has dissappeared.  

I was just adding a sighting confirmation to the original poster
Antoniu-George SAVU's report of this problem that I have also seen a
problem that looks identical.  So I don't think this is an isolated
problem.  Unfortunately the test case has gone away for me.

Bob

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
