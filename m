From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: Stale handle error on RHEL4 (2.6.9-22.ELsmp)
Date: Thu, 16 Feb 2006 07:44:05 -0800 (PST)
Message-ID: <20060216154405.29704.qmail@web51615.mail.yahoo.com>
References: <1140104151.8891.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9lIj-0006Vk-CP
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:44:13 -0800
Received: from web51615.mail.yahoo.com ([206.190.39.127])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1F9lIj-00073W-2V
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:44:13 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140104151.8891.38.camel@lade.trondhjem.org>
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

Hi Trond,
     But this is different than behaviour of NFS=20
     on other platforms. On other platforms like=20
     AIX, root of exported fses need not be=20
     on shared disk.
     Anyways, i will try out the thing suggested
     by you and post the result tomorrow.

thanks,
 kiran


--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> On Thu, 2006-02-16 at 07:34 -0800, mehta kiran
> wrote:
> > Hi Trond,
> >   partitions /dev/sdi1 and /dev/sdi2 are=20
> >   seen by both the systems on which server
> >   can start and their major/minor numbers
> >   are same on both the systems.
> >   Sfter server fails over to other system,
> >   output of exportfs and mount looks the same.
> >   Should /export directory which is exported
> >   with fsid=3D0 be on shared disk as well ?
>=20
> Probably, yes.
>=20
> Cheers,
>   Trond
>=20
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
