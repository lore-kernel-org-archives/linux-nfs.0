From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount ...
Date: Wed, 19 Feb 2003 01:56:59 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1199.195.252.45.39.1045648619.squirrel@www.zytor.com>
References: <3E50EC51.6022D3A7@moving-picture.com>
        <20030217152036.GA23116@terminus.zytor.com>
        <shsheb2lxde.fsf@charged.uio.no>
        <3E510686.6899E7BE@moving-picture.com>
        <15953.2794.981629.182213@charged.uio.no>
        <3E5120C4.9C03C7A6@moving-picture.com>
        <3E5265EA.14C644F5@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>, <autofs@linux.kernel.org>,
   <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from terminus.zytor.com ([63.209.29.3] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lQyq-0004k2-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 01:57:32 -0800
To: <james-p@moving-picture.com>
In-Reply-To: <3E5265EA.14C644F5@moving-picture.com>
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

>
> Fortunately, as autofs doesn't appear to attempt a umount until the
> mount point is 'free', then you shouldn't have this problem - unless you
> manually umount the mount point, or something goes wrong...
>

Well, it does, but the test is a sieve, rather than a true test, as there
is no protection against race conditions.  It's mostly there to avoid the
high overheard of the umount operation when it's not necessary or
desirable.

A user can come in between the test and the umount request, and autofs
depends on /bin/umount signalling error without harmful side effects.

    -hpa





-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
