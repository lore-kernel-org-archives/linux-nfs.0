From: Michael Buesch <fsdeveloper@yahoo.de>
Subject: Re: processes stuck in D state
Date: Tue, 6 May 2003 19:31:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305061931.14023.fsdeveloper@yahoo.de>
References: <D38AFB3080F3D311807300B0D0203E53033A9572@MERCURY>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp014.mail.yahoo.com ([216.136.173.58])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D6Ks-0005TT-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 10:34:38 -0700
To: pwitting@Cyveillance.com
In-Reply-To: <D38AFB3080F3D311807300B0D0203E53033A9572@MERCURY>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday 06 May 2003 19:09, pwitting@Cyveillance.com wrote:
> Actually, I have seen this on the server before, specifically
> When using an older version of IBM's JFS for Linux with RH 7.3

I'm running ext3 on the server.

> I worked with the JFS team and JFS v1.1.0 and kernel 2.4.20
> seemed to stabilize it, at least I've seen no more "freezes"
> as a result.

server-kernel is 2.4.21-pre6.

> Judging by your mail address this might be your
> problem as well.

You refer to the "fs" in my e-mail address? :)
The "fs" stands for "FreeSoftware".

> One noticeable symptom is that cd'ing to an affected dir and
> attempting an ls would also freeze (I had a large (20GB+) file
> copy going, so I usually knew what the affected dir was.
>
> Two other things that helped:
> 1) increasing the # of nfs threads (120 or more)
> 2) ensuring the uid/gid the remote thread was using existed on
> the server. (sounds stupid but it helped)
>
> neither "cured" the issue, but it went from being reproducible
> to being occasional.
>
> Good Luck.

thanks. :)

=2D --=20
Regards Michael B=FCsch
http://www.8ung.at/tuxsoft
 19:26:58 up  3:18,  2 users,  load average: 1.01, 1.08, 1.05
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t/FhoxoigfggmSgRAqgLAJ9hGo5l2c1y/oiZxamh/M88avZYIwCggzTc
lgyMmTHSGnxK17Xfq1Vb/eg=3D
=3DNi5P
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
