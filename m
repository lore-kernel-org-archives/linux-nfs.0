From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: redhat 2.4.18-5 client huge slowdown
Date: Thu, 11 Jul 2002 14:29:34 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207111429.34983.rdieter@math.unl.edu>
References: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SjdE-0000kM-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 12:29:40 -0700
Received: from duran.unl.edu (IDENT:iEyqkCJn+5VIwskM92UGb5YWV/+suHaa@duran.unl.edu [129.93.50.93])
	by mathstat.unl.edu (8.9.3/8.9.3) with ESMTP id OAA11556
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 14:29:38 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net>
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

Rex Dieter <rdieter@math.unl.edu> wrote:
> Raphael Clifford wrote:
> > I was wondering if everyone else is experiencing huge nfs write
> > slowdowns using redhat kernel 2.4.18-5 (as opposed to 2.4.18-4).  I a=
m
>
> Yes, I've also experienced a huge nfs client slowdown (~50k/sec writes)=
 on
> 'sync' nfs mounts with the 2.4.18-5 kernel... See me bugzilla report:
> http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D67199
=2E..

Here's some interesting data (on switched fast ethernet) to chew on (usin=
g=20
Redhat's 2.4.18-5 kernel on both server and client):
Server(1)  Client(2)  Speed=20
async      async     ~8.5MB/sec=20
async      sync      ~6.5MB/sec=20
sync       async     ~350K/sec=20
sync       sync      ~50k/sec=20
=20
(1) using the 'async/sync' option in /etc/exports
(2) using the 'async/sync' option when mounting, ie, mount -t nfs -o sync=
 ...

Is this really the kind of performance I should expect to get? (I hope no=
t)

-- Rex


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
