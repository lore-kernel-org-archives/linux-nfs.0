From: Patrick O'Reilly <patrick.oreilly@uni.edu>
Subject: Re: Solaris 8 - RH 7.1 NFS Bugs
Date: Thu, 13 Jun 2002 14:04:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00dc01c2130d$29204b00$66f1a186@OREILLY>
References: <017501c20b44$b291b390$66f1a186@OREILLY>
 <shslm9v2qb5.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from viper.uni.edu ([134.161.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17IZta-0004Mi-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Jun 2002 12:04:34 -0700
Received: from OREILLY ([134.161.241.102]) by uni.edu (PMDF V6.1-1 #39731)
 with SMTP id <01KIVUWPO2DM8Y6E1E@uni.edu> for nfs@lists.sourceforge.net; Thu,
 13 Jun 2002 14:04:23 -0500 (CDT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Just an update:

I added 'nosuid,log' to the share command on my Solaris 8 system in
/etc/dfs/dfstab, and now all the mounts on my RH 7.1 boxes stay put, as well
as does the data....even when a non-root user logs on.  I can't explain
this, other than to say it worked.  Also, no more error messages as shown
below. Thanks!

Patrick

----- Original Message -----
From: "Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "Patrick O'Reilly" <patrick.oreilly@uni.edu>
Cc: <nfs@lists.sourceforge.net>
Sent: Tuesday, June 04, 2002 7:15 AM
Subject: Re: [NFS] Solaris 8 - RH 7.1 NFS Bugs


> >>>>> " " == Patrick O'Reilly <patrick.oreilly@uni.edu> writes:
>
>      > johnstown kernel: nfs_statfs: statfs error = 13 johnstown
>      > kernel: call_verify: server requires stronger authentication.
>
> Linux does not yet support strong (kerberos) authentication on the
> server. We're working on that, but an official patch is still pending.
>
> The reason it works for 'root' is that Sun decided that 'automount'
> daemons (that are running as root) should still be allowed to mount
> these partitions despite not having any kerberos credentials...
>
> Cheers,
>   Trond
>
> _______________________________________________________________
>
> Don't miss the 2002 Sprint PCS Application Developer's Conference
> August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
