From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: redhat 2.4.18-5 client huge slowdown
Date: Thu, 11 Jul 2002 14:08:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207111408.48625.rdieter@math.unl.edu>
References: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SjJ7-0004Hp-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 12:08:53 -0700
Received: from duran.unl.edu (IDENT:Y72cTw4l3KtkPyVC70hV1//xToL/ipL+@duran.unl.edu [129.93.50.93])
	by mathstat.unl.edu (8.9.3/8.9.3) with ESMTP id OAA10817
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 14:08:51 -0500
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

On Thursday 11 July 2002 2:02 pm, Trond Myklebust wrote:
> >>>>> " " =3D=3D Rex Dieter <rdieter@math.unl.edu> writes:
>      > Yes, I've also experienced a huge nfs client slowdown (~50k/sec
>      > writes) on 'sync' nfs mounts with the 2.4.18-5 kernel... See me
>      > bugzilla report:
>      > http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D67199 and =
a
>      > similar report as well:
>      > http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D67461
>
>      > The only way I found to get any sort of respectable performance
>      > out of 2.4.18-5 was to mount 'async'. *ack*
>
> For 2.4.18-5 RedHat appears to have decided to set the default r/wsize
> to 4k.=20

For me, the r/wsize made no significant difference as long as the 'sync'=20
option was used.  Write speeds consistantly stayed ~50k/sec.

-- Rex



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
