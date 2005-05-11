From: Chris Penney <cpenney@gmail.com>
Subject: Re: NFS Performance issues
Date: Wed, 11 May 2005 10:15:25 -0400
Message-ID: <111aefd05051107151d4624b8@mail.gmail.com>
References: <BEA6E6AA.11AD0%jblock@mrsc.ucsf.edu>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Block <jblock@mrsc.ucsf.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DW2Os-0004b2-Sh
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 18:22:06 -0700
Received: from wproxy.gmail.com ([64.233.184.206])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DW2Os-0002Z0-HK
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 18:22:06 -0700
Received: by wproxy.gmail.com with SMTP id 69so413793wra
        for <nfs@lists.sourceforge.net>; Wed, 11 May 2005 18:22:05 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <BEA6E6AA.11AD0%jblock@mrsc.ucsf.edu>
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

> We have 683MB of test data that we were playing with that represents the
> file sizes that our users play with.  There are several small files in th=
is
> set so there is a lot of writes and commits.  Our users generally work wi=
th
> data sets in the multiple gigabyte range.

This sounds similar to some of the CAE analysis work that some of the
NFS servers I maintain handle.  Our Sun 480s w/ Veritas do a
reasonable job, but the linux boxes we have blow their doors off.

We are using JFS file systems (which was a huge improvement for us)
and using the 2.6 device-mapper to stripe across four 1TB luns.  We
have dual cpu boxes w/ hyperthreading enabled and use 128 nfs threads.
 All clients use a 32k r/wsize (which was also an improvement).  We
don't use async for reliability reasons (I'm not sure with out setup
it would matter than much).

I aslo use the following in sysctl.conf:

net.core.rmem_default =3D 262144
net.core.wmem_default =3D 262144
net.core.rmem_max =3D 8388608
net.core.wmem_max =3D 8388608
net.ipv4.tcp_rmem =3D 4096 87380 8388608
net.ipv4.tcp_wmem =3D 4096 65536 8388608
net.ipv4.tcp_mem =3D 8388608 8388608 8388608

I can't say those tuneing options are formally tested.  Perhaps
something with more understand could comment on them.

   Chris


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
