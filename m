From: Chris Penney <cpenney@gmail.com>
Subject: Re: NFS Client Performance Question
Date: Wed, 13 Jul 2005 16:40:03 -0400
Message-ID: <111aefd050713134026ad13df@mail.gmail.com>
References: <111aefd050713113071f0c9ce@mail.gmail.com>
	 <1121285771.8234.7.camel@lade.trondhjem.org>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dso2C-0005uj-CA
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 13:40:48 -0700
Received: from wproxy.gmail.com ([64.233.184.202])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Dso2B-0000LS-8P
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 13:40:48 -0700
Received: by wproxy.gmail.com with SMTP id i35so266246wra
        for <nfs@lists.sourceforge.net>; Wed, 13 Jul 2005 13:40:35 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1121285771.8234.7.camel@lade.trondhjem.org>
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

On 7/13/05, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> on den 13.07.2005 Klokka 14:30 (-0400) skreiv Chris Penney:
> > The client mount options are:
> >    rw,nosuid,bg,hard,intr,nfsvers=3D3,tcp,rsize=3D32768,wsize=3D32768
>=20
> Does this match the entry for this mountpoint in /proc/mounts ?

Yes, and if I do a streaming write test I do in fact see only 32k
async writes even with '-r 4k'.

The entry is:
server:/s on /s/nicfs5 type nfs
(rw,nosuid,bg,hard,intr,nfsvers=3D3,tcp,rsize=3D32768,wsize=3D32768,addr=3D=
1.1.1.1)

   Chris


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
