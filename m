From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Mon, 30 Oct 2006 23:53:02 -0500
Message-ID: <4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
References: <20061031001248.GA19915@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gelca-0008HR-9l
	for nfs@lists.sourceforge.net; Mon, 30 Oct 2006 20:53:08 -0800
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GelcX-00015d-4v
	for nfs@lists.sourceforge.net; Mon, 30 Oct 2006 20:53:09 -0800
Received: by ug-out-1314.google.com with SMTP id p27so1367295ugc
	for <nfs@lists.sourceforge.net>; Mon, 30 Oct 2006 20:53:03 -0800 (PST)
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20061031001248.GA19915@uio.no>
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

On 10/30/06, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> [Please Cc me on any replies, I'm not subscribed to the list]
>
> Hi,
>
> We have a machine here running nfs-utils 1.0.10 serving Kerberos over NFSv4,
> and every now and then (typically about once a day, but that varies) mounts
> just stop working. rpc.svcgssd still runs, packets fly back and forth, but
> mount simply refuses. Restarting rpc.svcgssd fixes the problems
> immediately -- hosts mounting NFSv4 non-kerberized work just fine.
>
> I've put up a transcript at
> http://home.samfundet.no/~sesse/svcgssd-dying.log.bz2 -- hope you get
> something useful out of it. (I guess we'll have to change the keytab now, but
> hey :-) ) Only the last few calls in there are buggy; the rest are all good.
>
> /* Steinar */

Hello Steinar,
I don't see anything in the svcgssd output indicating there was any
kind of error.

When you say "packets fly back and forth, but mount simply refuses",
is there any kind of delay (i.e. 30 second timeout) or does the mount
fail pretty quickly?  Do you see the "typical" error message(s) from
mount?

What kernel is this with?

K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
