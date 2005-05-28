From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS Performance with sync or async
Date: Fri, 27 May 2005 19:45:12 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539BBA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DbrKG-0004Nc-N1
	for nfs@lists.sourceforge.net; Fri, 27 May 2005 19:45:24 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DbrKF-0006Sa-2A
	for nfs@lists.sourceforge.net; Fri, 27 May 2005 19:45:24 -0700
To: "George Garvey" <tmwg-nfs@inxservices.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>    We use a copy of each client's data and their installed program
> version for testing and support issues. The data can be updated using
> a simple zip file from the client.
>    This is all stored on an NFS server for support's use. Server and
> client are both on the same gigabit switch. The LAN she is connected
> to has only gigabit connections on the switch. We're using TCP anyway
> for everything (including NFS over a PTP T1: the T1 does go through
> the same switch).
>    Just FYI, I tried both UDP and TCP, and it seems that TCP was
> slightly faster. However, I was using a system I couldn't shut down,
> etc., so I didn't remove caching effects well.
>=20
>    However, what changed things was removing sync from the mount. I
> remounted the directory that stores the client systems without async
> instead of sync (it is a subdirectory of a directory already mounted
> sync).

to clarify, you are using the "sync" mount option on your NFS clients?
why did you initially decide to use "sync"?

without knowing more details about your situation, let me suggest you
might find something useful in the Linux NFS FAQ:

  http://nfs.sourceforge.net/


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
