From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RE: Linux client on Solaris 7 NFS server
Date: Tue, 30 Dec 2003 07:50:39 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B05@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbM8t-0002P0-Se
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 07:50:47 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AbM8t-0003a6-Gt
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 07:50:47 -0800
To: <dwight@supercomputer.org>
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

hi dwight-

> If the Solaris Server is locking up, this is a problem with
> Solaris. It might be somehow triggered by Linux, but that is
> absolutely no excuse for a server problem. The server should
> just stay up.

i think "locking up" is a pretty general description of the
problem.  we need to have precise details from wade about
the server's behavior.  after all, it could be bad hardware,
rather than any problem specific to the NFS implementation.

> "Sensitive" should refer to performance. My experience is that
> Linux NFS clients exhibit horrible performance issues with Sun
> servers in standard, out-of-the-box configurations. That's in
> comparison to using pure Sun or pure Linux Server/Client
> combinations.

again, specific details about the problem would be very helpful.
just saying that "they exhibit horrible performance out of the
box" does not reflect the specifics of your environment, nor
what kind of analysis and tuning you did to resolve the issues.
was this a problem with default settings, or were there software,
network, or hardware issues you encountered?


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
