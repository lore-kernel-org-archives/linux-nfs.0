From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: "nfs warning: mount version older than kernel"
	reported for 2.6.4 kernel on Fedora Core 1.0
Date: Fri, 19 Mar 2004 14:39:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079725155.2530.30.camel@lade.trondhjem.org>
References: <41089CB27BD8D24E8385C8003EDAF7AB084833@karl.alexa.com>
	 <20040319184931.GF29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Guolin Cheng <guolin@alexa.com>, "NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4Ppy-0005R5-Sk
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 11:39:22 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B4Ppw-0008SY-0H
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 11:39:20 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040319184931.GF29237@perlsupport.com>
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

P=E5 fr , 19/03/2004 klokka 13:49, skreiv Chip Salzenberg:
> According to Guolin Cheng:
> > Nfs complains when I compile and use kernel 2.6.4 on Fedora Core 1.0.
>=20
> I've been seeing this too, on a Debian system.  I should have realized
> it was up to me to report this and/or fix it.  :-,
>=20
> So, what's the deal, guys?

The deal is that several people have made changes to the NFS mount
structures.

One such change is to allow NFSv2/v3 to use RPCSEC_GSS (BTW: we're
*still* waiting to hear from this list about including the RPCSEC_GSS +
NFSv4 support daemons into the official nfs-utils) the other is a change
requested by the SELinux peoples to allow them to pass security context
information into the kernel as part of the mount process.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
